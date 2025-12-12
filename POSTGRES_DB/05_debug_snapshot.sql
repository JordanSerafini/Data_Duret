-- DEBUG HEADERS
\c mde_erp;

SELECT type_document, count(*) FROM document.entete_document GROUP BY type_document;
SELECT count(*) FROM ref.element WHERE societe_id = 1;

-- Test the SELECT query from seed
SELECT 
    d.id, e.id
FROM document.entete_document d
CROSS JOIN LATERAL (SELECT * FROM ref.element WHERE societe_id = 1 ORDER BY RANDOM() LIMIT 5) e
WHERE d.type_document = 'FACTURE';
