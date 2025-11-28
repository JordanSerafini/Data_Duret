const sql = require('mssql/msnodesqlv8');

const config = {
    server: 'SRV-SAGE\\SAGE100',
    driver: 'msnodesqlv8',
    options: {
        trustedConnection: true,
        trustServerCertificate: true,
        encrypt: false
    }
};

async function scanDatabases() {
    console.log('='.repeat(80));
    console.log('SCAN DES BASES DE DONNÉES - SRV-SAGE\\SAGE100');
    console.log('='.repeat(80));
    console.log('');

    let pool;
    const results = [];

    try {
        // Connexion au serveur
        console.log('📡 Connexion au serveur...');
        pool = await sql.connect(config);
        console.log('✅ Connecté avec succès\n');

        // Liste toutes les bases de données
        console.log('📋 Récupération de la liste des bases de données...');
        const dbListQuery = `
            SELECT name
            FROM sys.databases
            WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
            ORDER BY name
        `;

        const dbListResult = await pool.request().query(dbListQuery);
        const databases = dbListResult.recordset.map(row => row.name);

        console.log(`✅ ${databases.length} base(s) trouvée(s)\n`);
        console.log('-'.repeat(80));

        // Scanner chaque base de données
        for (let i = 0; i < databases.length; i++) {
            const dbName = databases[i];
            console.log(`\n[${i + 1}/${databases.length}] Analyse de: ${dbName}`);

            try {
                // Vérifier si la table F_DOCENTETE existe
                const checkTableQuery = `
                    SELECT COUNT(*) as tableExists
                    FROM [${dbName}].INFORMATION_SCHEMA.TABLES
                    WHERE TABLE_NAME = 'F_DOCENTETE'
                `;

                const tableCheck = await pool.request().query(checkTableQuery);
                const tableExists = tableCheck.recordset[0].tableExists > 0;

                if (tableExists) {
                    console.log('  ✓ Table F_DOCENTETE trouvée');

                    // Récupérer les informations
                    const dataQuery = `
                        SELECT
                            MAX(DO_Date) as lastDocDate,
                            COUNT(*) as rowCount
                        FROM [${dbName}].dbo.F_DOCENTETE
                    `;

                    const dataResult = await pool.request().query(dataQuery);
                    const data = dataResult.recordset[0];

                    results.push({
                        database: dbName,
                        hasTable: true,
                        lastDocDate: data.lastDocDate,
                        rowCount: data.rowCount,
                        error: null
                    });

                    console.log(`  ✓ Date du document le plus récent: ${data.lastDocDate ? new Date(data.lastDocDate).toISOString().split('T')[0] : 'NULL'}`);
                    console.log(`  ✓ Nombre de lignes: ${data.rowCount}`);
                } else {
                    console.log('  ✗ Table F_DOCENTETE non trouvée');
                    results.push({
                        database: dbName,
                        hasTable: false,
                        lastDocDate: null,
                        rowCount: 0,
                        error: null
                    });
                }

            } catch (err) {
                console.log(`  ⚠️  Erreur d'accès: ${err.message}`);
                results.push({
                    database: dbName,
                    hasTable: false,
                    lastDocDate: null,
                    rowCount: 0,
                    error: err.message
                });
            }
        }

        console.log('\n' + '='.repeat(80));
        console.log('TABLEAU RÉCAPITULATIF');
        console.log('='.repeat(80));
        console.log('');

        // Afficher le tableau récapitulatif
        const validResults = results.filter(r => r.hasTable && r.lastDocDate);
        const invalidResults = results.filter(r => !r.hasTable || !r.lastDocDate);

        if (validResults.length > 0) {
            // Trier par date décroissante
            validResults.sort((a, b) => {
                if (!a.lastDocDate) return 1;
                if (!b.lastDocDate) return -1;
                return new Date(b.lastDocDate) - new Date(a.lastDocDate);
            });

            console.log('📊 BASES AVEC TABLE F_DOCENTETE:');
            console.log('-'.repeat(80));
            console.log(
                'Base de données'.padEnd(40) +
                'Dernière date'.padEnd(20) +
                'Nb lignes'.padStart(10)
            );
            console.log('-'.repeat(80));

            validResults.forEach((result, index) => {
                const dateStr = result.lastDocDate
                    ? new Date(result.lastDocDate).toISOString().split('T')[0]
                    : 'NULL';

                const marker = index < 3 ? '⭐' : '  ';
                console.log(
                    marker + ' ' +
                    result.database.padEnd(38) +
                    dateStr.padEnd(20) +
                    result.rowCount.toString().padStart(10)
                );
            });

            // Afficher le TOP 3
            console.log('\n' + '='.repeat(80));
            console.log('🏆 TOP 3 BASES (Documents les plus récents)');
            console.log('='.repeat(80));

            const top3 = validResults.slice(0, 3);
            top3.forEach((result, index) => {
                const dateStr = new Date(result.lastDocDate).toISOString().split('T')[0];
                console.log(`\n${index + 1}. ${result.database}`);
                console.log(`   📅 Dernière date: ${dateStr}`);
                console.log(`   📊 Nombre de lignes: ${result.rowCount}`);
            });
        }

        if (invalidResults.length > 0) {
            console.log('\n' + '-'.repeat(80));
            console.log('⚠️  BASES SANS TABLE F_DOCENTETE OU AVEC ERREUR:');
            console.log('-'.repeat(80));
            invalidResults.forEach(result => {
                if (result.error) {
                    console.log(`  ✗ ${result.database} - Erreur: ${result.error}`);
                } else {
                    console.log(`  ✗ ${result.database} - Table non trouvée`);
                }
            });
        }

        console.log('\n' + '='.repeat(80));
        console.log(`✅ Scan terminé: ${validResults.length} base(s) valide(s), ${invalidResults.length} base(s) sans table/erreur`);
        console.log('='.repeat(80));

    } catch (err) {
        console.error('❌ Erreur fatale:', err.message);
        console.error(err);
        process.exit(1);
    } finally {
        if (pool) {
            await pool.close();
        }
    }
}

// Exécution
scanDatabases().catch(err => {
    console.error('❌ Erreur non gérée:', err);
    process.exit(1);
});
