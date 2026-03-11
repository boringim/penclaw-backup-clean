/**
 * Backup SQLite databases found in the OpenClaw directory.
 * Uses the 'sqlite3' Node.js module (no external CLI).
 * Outputs log lines prefixed with ISO timestamps.
 * Enhanced with retry logic for busy databases.
 */

const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3');

// Configuration
const openclawDir = process.env.OPENCLAW_HOME || 'C:\\Users\\Administrator\\.openclaw';
const backupDir = path.join(openclawDir, 'backup', 'db');
const logPrefix = () => new Date().toISOString();
const MAX_RETRIES = 3;
const RETRY_DELAY_MS = 2000;

// Ensure backup directory exists
try {
    fs.mkdirSync(backupDir, { recursive: true });
} catch (e) {
    console.error(`[${logPrefix()}] FAILED to create backup dir: ${e.message}`);
    process.exit(1);
}

// Find all .sqlite and .db files (excluding node_modules, .git, etc.)
function findDatabases(dir, list = []) {
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
        if (entry.name === 'node_modules' || entry.name === '.git' || entry.name.startsWith('.')) {
            continue;
        }
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            try {
                findDatabases(fullPath, list);
            } catch (e) {
                // Skip directories we can't read
                console.warn(`[${logPrefix()}] SKIP DIR (unreadable): ${fullPath}`);
            }
        } else if (/\.(sqlite|db)$/i.test(entry.name)) {
            list.push(fullPath);
        }
    }
    return list;
}

// Backup a single database with retry logic
function backupDatabase(dbPath, callback) {
    const dbName = path.basename(dbPath);
    const backupPath = path.join(backupDir, dbName);

    let attempt = 0;

    function attemptBackup() {
        attempt++;
        try {
            console.log(`[${logPrefix()}] Attempting backup of ${dbName} (try ${attempt}/${MAX_RETRIES})...`);

            const sourceDb = new sqlite3.Database(dbPath, sqlite3.OPEN_READONLY, (openErr) => {
                if (openErr) {
                    if (openErr.message && openErr.message.includes('SQLITE_BUSY') && attempt < MAX_RETRIES) {
                        console.log(`[${logPrefix()}] Database busy, retrying in ${RETRY_DELAY_MS}ms...`);
                        setTimeout(attemptBackup, RETRY_DELAY_MS);
                        return;
                    }
                    return callback(openErr);
                }

                // Use .backup() to create a consistent backup
                sourceDb.backup(backupPath, (backupErr) => {
                    sourceDb.close((closeErr) => {
                        if (backupErr) {
                            if (backupErr.message && backupErr.message.includes('SQLITE_BUSY') && attempt < MAX_RETRIES) {
                                console.log(`[${logPrefix()}] Backup busy, retrying in ${RETRY_DELAY_MS}ms...`);
                                setTimeout(attemptBackup, RETRY_DELAY_MS);
                                return;
                            }
                            callback(backupErr);
                        } else if (closeErr) {
                            callback(closeErr);
                        } else {
                            callback(null, dbName, backupPath);
                        }
                    });
                });
            });
        } catch (err) {
            if (err.message && err.message.includes('SQLITE_BUSY') && attempt < MAX_RETRIES) {
                console.log(`[${logPrefix()}] Caught busy error, retrying in ${RETRY_DELAY_MS}ms...`);
                setTimeout(attemptBackup, RETRY_DELAY_MS);
                return;
            }
            callback(err);
        }
    }

    attemptBackup();
}

// Main execution
console.log(`[${logPrefix()}] Starting SQLite backup...`);

try {
    const dbs = findDatabases(openclawDir);
    console.log(`[${logPrefix()}] Found ${dbs.length} database(s): ${dbs.map(p => path.basename(p)).join(', ')}`);

    let successCount = 0;
    let index = 0;

    function next() {
        if (index >= dbs.length) {
            console.log(`[${logPrefix()}] Backup complete. ${successCount}/${dbs.length} succeeded.`);
            process.exit(successCount > 0 ? 0 : 1);
            return;
        }
        const dbPath = dbs[index++];
        const dbName = path.basename(dbPath);
        backupDatabase(dbPath, (err, name, backupPath) => {
            if (err) {
                console.error(`[${logPrefix()}] FAILED: ${dbName} - ${err.message}`);
            } else {
                console.log(`[${logPrefix()}] SUCCESS: ${dbName} -> ${backupPath}`);
                successCount++;
            }
            setTimeout(next, 10); // slight delay between operations
        });
    }

    next();
} catch (err) {
    console.error(`[${logPrefix()}] Fatal error: ${err.message}`);
    process.exit(1);
}
