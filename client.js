const sql = require('mssql/msnodesqlv8');
const fs = require('fs');
const path = require('path');

const config = {
    server: 'SRV-SAGE\\SAGE100',
    database: 'MDE_DOS_DURET',
    driver: 'msnodesqlv8',
    options: {
        trustedConnection: true,
        trustServerCertificate: true,
        encrypt: false
    }
};

const outputDir = path.join(__dirname, 'EXPORT_SCHEMA');

async function main() {
    try {
        console.log("1. Connexion au serveur...");
        await sql.connect(config);

        // Vérification de la base connectée
        const dbCheck = await sql.query("SELECT DB_NAME() AS CurrentDB");
        const currentDB = dbCheck.recordset[0].CurrentDB;
        console.log(`   -> Connecté sur : ${currentDB}`);

        if (currentDB === 'master') {
            console.warn("⚠️  ATTENTION : Tu es sur 'master'. Les tables Sage ne seront pas visibles.");
            console.warn("   -> L'utilisateur Windows n'a peut-être pas les droits sur MDE_DOS_DURET.");
        }

        console.log("2. Récupération de la structure (Tables & Colonnes)...");
        
        const query = `
            SELECT 
                t.TABLE_SCHEMA,
                t.TABLE_NAME,
                c.COLUMN_NAME,
                c.DATA_TYPE,
                c.CHARACTER_MAXIMUM_LENGTH,
                c.IS_NULLABLE
            FROM INFORMATION_SCHEMA.TABLES t
            INNER JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME
            WHERE t.TABLE_TYPE = 'BASE TABLE'
            ORDER BY t.TABLE_NAME, c.ORDINAL_POSITION
        `;

        const result = await sql.query(query);
        const rows = result.recordset;

        console.log(`   -> ${rows.length} colonnes trouvées au total.`);

        if (rows.length === 0) {
            console.error("❌ Aucune donnée trouvée. Vérifie les droits ou le nom de la base.");
            await sql.close();
            return;
        }

        const schema = {};
        rows.forEach(row => {
            const tableName = `${row.TABLE_SCHEMA}.${row.TABLE_NAME}`;
            if (!schema[tableName]) {
                schema[tableName] = [];
            }
            schema[tableName].push({
                column: row.COLUMN_NAME,
                type: row.DATA_TYPE,
                length: row.CHARACTER_MAXIMUM_LENGTH,
                nullable: row.IS_NULLABLE
            });
        });

        if (!fs.existsSync(outputDir)) {
            fs.mkdirSync(outputDir);
        }

        const jsonPath = path.join(outputDir, 'sage_structure.json');
        fs.writeFileSync(jsonPath, JSON.stringify(schema, null, 2));
        console.log(`✅ Fichier JSON généré : ${jsonPath}`);

        let mdContent = `# Structure de la base ${currentDB}\n\n`;
        for (const [table, columns] of Object.entries(schema)) {
            mdContent += `### 📦 Table : ${table}\n`;
            mdContent += `| Colonne | Type | Nullable |\n|---|---|---|\n`;
            columns.forEach(c => {
                const typeInfo = c.length ? `${c.type}(${c.length})` : c.type;
                mdContent += `| **${c.column}** | ${typeInfo} | ${c.nullable} |\n`;
            });
            mdContent += `\n---\n`;
        }
        
        const mdPath = path.join(outputDir, 'sage_structure.md');
        fs.writeFileSync(mdPath, mdContent);
        console.log(`✅ Fichier Markdown généré : ${mdPath}`);

        await sql.close();
        console.log("Terminé avec succès.");

    } catch (err) {
        console.error("ERREUR CRITIQUE :", err);
    }
}

main();