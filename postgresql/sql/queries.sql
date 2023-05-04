
-- Las personas que tienen una inscrpcion en un curso 
SELECT 
   Personas.Nombre,   
   Personas.Apellidos,   
   Personas.numero_dni,
   Empresas.Nombre
FROM 
   Personas
   LEFT OUTER JOIN Empresas ON (Personas.EmpresaId = Empresas.id)   
   INNER JOIN Inscripciones ON (Inscripciones.PersonaId = Personas.id)
WHERE
   extract('month' FROM Inscripciones.fecha) BETWEEN 5 AND 11;


--- Busquedas con textos e indices invertidos
select to_tsvector('spanish', 'Introducción a SQL');

select to_tsquery('spanish','Introducción & SQL');

select titulo from cursos;

explain select titulo 
from cursos
where
  titulo @@ to_tsquery('spanish','Introducción');

explain select titulo 
from cursos
where
  to_tsvector('spanish', titulo ) @@ to_tsquery('spanish','Introducción');

-- union
-- distinct
-- like %%