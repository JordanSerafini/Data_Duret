const sql = require('mssql/msnodesqlv8');
const fs = require('fs');
const path = require('path');

const baseConfig = {
    server: 'SRV-SAGE\\SAGE100',
    driver: 'msnodesqlv8',
    options: {
        trustedConnection: true,
        trustServerCertificate: true,
        encrypt: false
    }
};

const rootOutputDir = path.join(__dirname, 'EXPORT_SCHEMA_FULL');

async function main() {
    let globalPool = null;

    try {
        console.log("🔍 1. Connexion au serveur pour lister les bases...");
        globalPool = await new sql.ConnectionPool(baseConfig).connect();

        const resultDBs = await globalPool.request().query(`
            SELECT name 
            FROM sys.databases 
            WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
            AND state_desc = 'ONLINE'
            ORDER BY name
        `);

        const databases = resultDBs.recordset.map(row => row.name);
        console.log(`📋 ${databases.length} bases de données trouvées.`);
        
        await globalPool.close();

        for (const dbName of databases) {
            console.log(`\n------------------------------------------------`);
            console.log(`🔄 Traitement de : ${dbName}`);

            const dbConfig = {
                ...baseConfig,
                database: dbName
            };

            let pool = null;
            try {
                pool = await new sql.ConnectionPool(dbConfig).connect();
                console.log(`   ✅ Connexion réussie à ${dbName}`);

                const querySchema = `
                    SELECT 
                        t.TABLE_SCHEMA, t.TABLE_NAME, 
                        c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH, c.IS_NULLABLE
                    FROM INFORMATION_SCHEMA.TABLES t
                    INNER JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME
                    WHERE t.TABLE_TYPE = 'BASE TABLE'
                    ORDER BY t.TABLE_NAME, c.ORDINAL_POSITION
                `;

                const resultSchema = await pool.request().query(querySchema);
                const rows = resultSchema.recordset;

                if (rows.length > 0) {
                    const dbDir = path.join(rootOutputDir, dbName);
                    if (!fs.existsSync(dbDir)) {
                        fs.mkdirSync(dbDir, { recursive: true });
                    }

                    const schema = {};
                    rows.forEach(row => {
                        const tableName = `${row.TABLE_SCHEMA}.${row.TABLE_NAME}`;
                        if (!schema[tableName]) schema[tableName] = [];
                        schema[tableName].push({
                            column: row.COLUMN_NAME,
                            type: row.DATA_TYPE,
                            length: row.CHARACTER_MAXIMUM_LENGTH,
                            nullable: row.IS_NULLABLE
                        });
                    });

                    fs.writeFileSync(path.join(dbDir, 'schema.json'), JSON.stringify(schema, null, 2));

                    let mdContent = `# Schema de ${dbName}\n\n`;
                    for (const [table, cols] of Object.entries(schema)) {
                        mdContent += `### ${table}\n| Colonne | Type | Nullable |\n|---|---|---|\n`;
                        cols.forEach(c => {
                            const typeLen = c.length ? `${c.type}(${c.length})` : c.type;
                            mdContent += `| **${c.column}** | ${typeLen} | ${c.nullable} |\n`;
                        });
                        mdContent += `\n`;
                    }
                    fs.writeFileSync(path.join(dbDir, 'schema.md'), mdContent);

                    console.log(`   💾 Fichiers sauvegardés dans /${dbName}`);
                } else {
                    console.log(`   ⚠️  Base vide ou tables inaccessibles.`);
                }

                await pool.close();

            } catch (err) {
                if (err.code === 'ELOGIN' || err.number === 4060) {
                    console.log(`   ⛔ Accès refusé pour l'utilisateur Windows (Ignoré).`);
                } else {
                    console.error(`   ❌ Erreur technique :`, err.message);
                }
                if (pool) await pool.close().catch(() => {});
            }
        }

        console.log("\n✅ --- TERMINÉ ---");

    } catch (err) {
        console.error("Erreur générale :", err);
    }
}

main();