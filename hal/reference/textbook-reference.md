# Textbook Reference: ER/EER, Relational Mapping, Constraints, and Normalization

Source basis: `Databaser pensumbok.pdf`, identified as *Database System Concepts, Seventh Edition* (Silberschatz, Korth, Sudarshan). Notes below are conservative paraphrases from the textbook pages listed in [`textbook-citations.md`](./textbook-citations.md). Page numbers refer to PDF pages. If OCR looked slightly noisy, I kept the statement high-level rather than forcing a precise wording.

## What matters most for this project

- Start with a conceptual model first, then map it to relations. The book treats ER design as the conceptual phase and relational schema design as the logical phase. The purpose is to describe data, relationships, and constraints before implementation details leak into the design. [pp. 270-272]
- Good database design tries to avoid both redundancy and incompleteness. Redundancy causes update inconsistencies; incompleteness makes valid states impossible to represent cleanly. [pp. 272-273, 332-337]
- ER/EER diagrams help you state structure and some constraints, but not all business rules fit naturally in schema-level constraints. Some rules must be enforced by application logic, triggers, or careful transaction handling. [pp. 174-182, 320-321, 344-348]

## ER modeling essentials

### Entity sets and attributes

- An entity is a distinguishable thing in the domain; an entity set groups entities of the same kind. Attributes describe each entity. [pp. 273-275]
- Keys in ER serve the same role as keys in relations: they identify entities uniquely. Candidate keys and primary keys apply to entity sets too. [pp. 285-286]
- Composite attributes should usually be decomposed into meaningful components when mapped to relations. Multivalued attributes usually become separate relations. Derived attributes are usually not stored directly. [pp. 278-280, 294-296]

### Relationship sets, cardinality, and participation

- Relationship sets model associations between entity sets. [pp. 275-277]
- Binary cardinalities express one-to-one, one-to-many, many-to-one, or many-to-many constraints. These are modeling choices about the real world, not just drawing style. [pp. 281-285]
- Participation matters:
  - `total participation`: every entity on that side must appear in at least one relationship instance.
  - `partial participation`: some entities may appear in none. [pp. 284-285]
- For project work, this is important because “must have” rules often correspond to total participation in ER, but the exact DB enforcement may still depend on how the schema is reduced and what SQL features are available. [pp. 284-285, 299-300]

### Weak entities

- Use a weak entity when something is existence-dependent on another entity and needs the owner’s key plus a discriminator to be identified. [pp. 288-289]
- Typical pattern:
  - weak entity primary key = owner primary key + weak entity discriminator
  - identifying relationship is many-to-one toward the owner
  - weak entity has total participation in that identifying relationship [pp. 288-289]
- This is often the right model for domain objects that only make sense inside a parent object, such as subrecords, versions, or line items.

## Common ER/EER modeling choices

### Attribute vs entity

- If something may need its own properties, multiple occurrences, or shared references, model it as an entity instead of a plain attribute. The textbook uses `phone` as the example: attribute form is simpler, entity form is more general. [pp. 310-311]
- If something is just a simple descriptive property and has no independent structure, keep it as an attribute. [pp. 310-311]

### Relationship vs entity

- A relationship is often enough when you are modeling an action or association between existing things.
- Promote it to an entity when the association itself needs extra data, lifecycle, or other relationships. The book’s registration example shows that both can work, but the “association as entity” approach is better if the registration record has additional information of its own. [pp. 311-312]

### Binary vs n-ary

- Binary relationships are often easier to work with.
- Some n-ary relationships should stay n-ary because splitting them can change the meaning.
- Others can be reified as an entity plus several binary relationships when that better captures the semantics. [pp. 312-313, 305-308]

### EER: specialization, generalization, and inheritance

- Specialization separates a broader entity set into subtypes with additional properties.
- Generalization factors out common structure from multiple lower-level entity sets into a higher-level one.
- Lower-level entity sets inherit attributes and relationship participation from higher-level ones. [pp. 300-304]
- Important subtype constraints:
  - `disjoint` vs `overlapping`
  - `total` vs `partial` completeness [pp. 300-305]
- In implementation, only use subtype structures when they represent real domain differences. Otherwise they add complexity without helping the project.

## Mapping ER/EER to relational schema

### Strong entities

- A strong entity set maps to a relation with one column per simple attribute.
- The entity primary key becomes the relation primary key. [pp. 293-294]

### Complex attributes

- Composite attributes map to their components, not usually to an extra combined column. [pp. 294-295]
- Multivalued attributes map to a separate relation containing:
  - the owner key
  - the multivalued attribute (or its components)
  - typically a composite primary key over the full combination [pp. 295-296]
- Derived attributes are generally not represented directly in the relational model. [p. 295]

### Weak entities

- A weak entity maps to a relation containing:
  - its own attributes
  - the owner’s key as a foreign key
  - a primary key made from owner key + discriminator [pp. 296-297]

### Relationship sets

- A relationship set maps to a relation containing the participating entity keys plus any relationship attributes. [pp. 297-298]
- The relation’s primary key depends on cardinality:
  - many-to-many: usually the combination of participant keys
  - many-to-one / one-to-many: the key on the “many” side can suffice
  - one-to-one: either side’s key can suffice, depending on design choice [pp. 286-288, 297-298]
- Foreign keys should reference the participating entity relations. [pp. 297-298]

### When separate relationship tables can be removed or merged

- The relationship table connecting a weak entity to its owner is often redundant and can be dropped. [pp. 298-299]
- A many-to-one relationship with total participation on the many side can often be merged into the many-side entity relation by carrying the referenced key there. That is how conceptual relationships often become familiar foreign-key columns in the final schema. [pp. 299-300]
- This explains an important design pattern:
  - in ER, use a relationship to make semantics explicit
  - in the relational schema, that relationship may collapse into a foreign-key attribute after reduction [pp. 290-300]

### EER reduction

- For subtype hierarchies, the book gives two main patterns:
  - one table for the supertype plus one for each subtype
  - or only subtype tables, but only when the generalization is disjoint and complete [pp. 307-308]
- The first pattern is safer and more flexible for most university-project schemas because it works better with foreign keys and avoids awkward redundancy when overlap or incompleteness exists. [pp. 307-308]

## Keys, foreign keys, and integrity constraints

### Keys

- A superkey uniquely identifies tuples.
- A candidate key is a minimal superkey.
- A primary key is the chosen candidate key. [pp. 72-74]
- Choose primary keys that are stable and unlikely to change. [p. 74]
- Composite keys are legitimate when uniqueness really depends on a combination of attributes. [pp. 73-74]

### Referential integrity and schema constraints

- Foreign keys enforce that a referencing value matches a key value in a referenced relation. [pp. 74-75, 178-180]
- Core SQL constraints covered by the text:
  - `not null`
  - `unique`
  - `check`
  - `primary key`
  - `foreign key` [pp. 175-180]
- `check` is useful for local domain rules such as valid ranges or enumerated values. [pp. 176-178]
- Referential actions like `on delete cascade` and `on update cascade` can encode some lifecycle rules, but they should be used intentionally because they change deletion/update behavior rather than merely rejecting invalid actions. [pp. 179-180]

## BCNF and 3NF in practical terms

### Why normalization matters

- Good relational design aims to store information without unnecessary repetition while still supporting useful queries. [p. 332]
- Repetition creates update anomalies and can block valid inserts. Decomposition is the remedy when one relation mixes facts that should be stored separately. [pp. 333-337]

### Functional dependencies

- Functional dependencies capture facts like “this determinant fixes those attributes.”
- They are central for deciding whether a relation should be decomposed. [pp. 338-341]

### BCNF

- A relation is in BCNF if every nontrivial functional dependency has a superkey on the left-hand side. [pp. 342-344]
- Practical reading: if a non-key attribute or non-key attribute group determines other attributes, the relation is probably mixing multiple facts and should be split. [pp. 343-344]
- BCNF is the preferred target when possible because it removes redundancy discoverable from functional dependencies. [pp. 342-348]

### 3NF

- 3NF is weaker than BCNF. It allows some dependencies that BCNF would reject, specifically to preserve dependencies while still avoiding the worst anomalies. [pp. 346-347]
- Use 3NF when a BCNF decomposition would lose dependency preservation and that dependency is important to enforce or reason about. [pp. 344-348]

### Lossless decomposition and dependency preservation

- Two decomposition goals matter:
  - `lossless`: joining the decomposed tables recreates the original information correctly
  - `dependency preserving`: important dependencies can still be checked without expensive joins [pp. 336-337, 344-348, 357-359]
- The textbook’s pragmatic conclusion is notable: if you cannot get both BCNF and dependency preservation, BCNF is often still preferable in SQL practice because general functional dependencies are hard to enforce directly anyway. [pp. 347-348]

## What should be enforced in schema vs application logic

### Good candidates for schema enforcement

- Entity identity and uniqueness: `primary key`, `unique`. [pp. 72-75, 175-176]
- Required fields: `not null`. [p. 175]
- Referential existence: `foreign key`. [pp. 74-75, 178-180]
- Simple domain and range rules: `check`, enum-like checks, positive numbers, date/year bounds. [pp. 176-178]
- Some ownership/lifecycle rules: carefully chosen cascades. [pp. 179-180]
- Some subtype/relationship choices can be reflected structurally in the schema itself by how tables are split and how keys are chosen. [pp. 297-308]

### Usually not handled cleanly by schema alone

- Arbitrary business predicates can be expensive to test, so DBMSs usually support only limited built-in constraint forms. [p. 174]
- Complex assertions and subquery-based checks are in the SQL standard, but the book says widely used systems generally do not support them. [pp. 181-182]
- General functional dependencies beyond key-like constraints are not directly supported by ordinary SQL DDL. [pp. 347-348]
- Functional requirements, workflow rules, authorization logic, and transaction sequencing belong partly outside the schema and must be considered at the application level too. [pp. 271-272, 320-321]

### Project rule of thumb

- Put stable structural invariants in the schema.
- Put UI/workflow/process rules in application logic.
- For complex cross-table business rules, prefer database-level enforcement only if your chosen DBMS actually supports it cleanly; otherwise document the rule and enforce it in service/application code, possibly backed by triggers if your stack supports them well. [pp. 181-182, 347-348]

## Design pitfalls to avoid

- Do not put another entity’s key into an ER entity as an ordinary attribute when the right concept is a relationship. In ER, that hides semantics and duplicates information. [pp. 309-310]
- Do not add participant keys as ordinary attributes of a relationship set; they are implicit in the relationship already. [p. 309]
- Do not overload a single relationship instance with what is really a multivalued fact. Reify it or model it as a multivalued structure instead. [pp. 309-310]
- Be careful with denormalized “convenience tables.” They may reduce joins but often reintroduce redundancy and update anomalies. [pp. 333-337]
- Choose schemas with expected future change in mind. The book explicitly recommends distinguishing fundamental constraints from policies that may change later. [pp. 321]

## Suggested takeaway for the assignment

- Build an ER/EER model that makes the domain semantics explicit first.
- Reduce it to a relational schema using standard mapping rules, merging many-to-one relationships into foreign keys where appropriate.
- Use primary keys, candidate uniqueness, foreign keys, `not null`, and local `check` constraints aggressively for stable invariants.
- Aim for BCNF unless a clear dependency-preservation reason pushes a relation to 3NF.
- Document any rule that cannot be enforced naturally in SQL schema alone and state whether it must be handled by application logic, trigger logic, or transaction-level procedures.
