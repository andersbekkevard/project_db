# Textbook Citation Map

Source: `Databaser pensumbok.pdf` = *Database System Concepts, Seventh Edition*. Page numbers below refer to PDF pages, not printed chapter page numbers.

Purpose: trace the claims used in [`textbook-reference.md`](./textbook-reference.md). I did not copy textbook prose verbatim; this is a paraphrase map.

## Core sections used

### PDF pp. 270-272, Chapter 6.1, design process

- Design phases: requirements, conceptual design, logical design, physical design.
- Conceptual schema should describe entities, attributes, relationships, and constraints.
- Functional requirements are part of design, not only data structure.
- Logical schema changes are harder later because application code depends on them.

Used for:
- “conceptual first, relational later”
- separating schema design from application/workflow concerns
- why careful early modeling matters

### PDF pp. 272-273, Chapter 6.1.2, redundancy and incompleteness

- Bad designs can be redundant.
- Bad designs can also be incomplete and fail to represent valid states.
- Design choices affect what can be modeled well.

Used for:
- motivation for normalization
- warning against storing repeated course/department facts in one table

### PDF pp. 273-289, Chapters 6.2-6.5, ER basics, cardinality, keys, weak entities

- Entity sets, attributes, relationship sets.
- Mapping cardinality: 1:1, 1:N, N:1, N:M.
- Total vs partial participation.
- Keys for entity sets and relationship sets.
- Weak entity sets, identifying relationships, discriminator attributes.

Used for:
- ER modeling definitions
- how relationship keys depend on cardinality
- when to model a weak entity

### PDF pp. 290-300, Chapters 6.6-6.7, ER to relational reduction

- Removing redundant attributes from conceptual entity sets.
- Mapping strong entities, composite attributes, multivalued attributes.
- Mapping weak entities.
- Mapping relationship sets and creating foreign keys.
- Redundant relationship schemas for weak-entity ownership.
- Merging many-to-one relationships into entity schemas when appropriate.

Used for:
- main relational mapping rules
- explanation of why an ER relationship can become a foreign-key column later

### PDF pp. 300-308, Chapter 6.8, EER features and reduction

- Specialization, generalization, attribute inheritance.
- Disjoint vs overlapping.
- Total vs partial completeness.
- Two main relational mapping patterns for generalization.
- Aggregation and how to map it.

Used for:
- subtype modeling guidance
- recommendation to prefer the supertype-plus-subtype-table approach in most project cases

### PDF pp. 309-313, Chapter 6.9, design issues

- Common ER mistakes.
- Entity vs attribute.
- Entity vs relationship.
- Binary vs n-ary relationships.

Used for:
- modeling guidelines and pitfalls
- deciding when to reify an association

### PDF pp. 320-321, Chapter 6.11, other aspects of design

- Functional requirements, authorization, workflow, schema evolution.
- Distinction between fundamental constraints and policy constraints that may change.

Used for:
- what belongs partly outside schema design
- advice on schema vs application logic
- future-proofing and policy-change awareness

## Relational keys and constraints

### PDF pp. 72-75, Chapter 2.3, keys and referential integrity

- Superkey, candidate key, primary key.
- Composite keys.
- Primary keys should be stable.
- Foreign-key constraint as a special case of referential integrity.
- Referenced attributes in standard foreign-key treatment are primary-key attributes.

Used for:
- key definitions
- guidance on composite/stable keys
- baseline referential integrity terminology

### PDF pp. 174-180, Chapter 4.4.1-4.4.7, SQL integrity constraints

- Integrity constraints preserve consistency.
- Typical supported constraints: `not null`, `unique`, `check`, `primary key`, `foreign key`.
- `check` is tuple-level and good for local domain rules.
- Referential integrity and cascade actions.
- Arbitrary predicates are expensive; DBMSs usually support only a limited subset efficiently.
- Deferred checking exists in the standard, but implementation support varies.

Used for:
- what the schema can enforce directly
- caution about DBMS support limits
- schema-level enforcement examples

### PDF pp. 181-182, Chapter 4.4.8, complex checks and assertions

- SQL standard allows richer checks and assertions.
- Such constraints can be expensive.
- Widely used systems generally do not support subqueries in `check` or general assertions.
- Equivalent behavior may need triggers if supported.

Used for:
- “application logic vs schema” boundary
- warning not to assume arbitrary business rules fit in portable SQL DDL

## Normalization and decomposition

### PDF pp. 332-337, Chapter 7.1, good relational designs

- Goal: avoid unnecessary redundancy while supporting retrieval.
- Denormalized combined relations repeat facts and cause anomalies.
- Decomposition is necessary to avoid repetition.
- Lossless decomposition is essential.

Used for:
- practical motivation for normalization
- examples of update anomaly and insert anomaly

### PDF pp. 338-341, Chapter 7.2, functional dependencies and keys

- Functional dependencies express determinant relationships among attributes.
- They support reasoning about keys and decomposition.

Used for:
- explanation of why BCNF/3NF are phrased using functional dependencies

### PDF pp. 342-345, Chapter 7.3.1, BCNF

- BCNF definition.
- Example showing non-key determinant causing violation.
- Standard BCNF decomposition idea.
- BCNF can conflict with dependency preservation.

Used for:
- BCNF summary
- “if a non-key determinant determines other attributes, split the relation”

### PDF pp. 346-348, Chapter 7.3.2-7.3.4, 3NF and tradeoffs

- 3NF definition and how it relaxes BCNF.
- Tradeoff between BCNF and dependency preservation.
- In SQL, arbitrary functional dependencies are hard to enforce directly.
- Textbook’s practical conclusion: BCNF is often still preferable if direct FD enforcement is unavailable.

Used for:
- concise comparison of BCNF vs 3NF
- schema vs application/database-feature enforcement discussion

### PDF pp. 357-359, Chapter 7.4.4, dependency preservation

- Formal definition of dependency preservation.
- Restrictions to decomposed relations.
- Dependency-preserving decomposition means the preserved dependencies imply the originals.

Used for:
- precise wording of dependency preservation in the notes

### PDF pp. 360-364, Chapter 7.5, decomposition algorithms

- BCNF decomposition algorithm and lossless property.
- 3NF synthesis algorithm.
- Example decomposing a “class” relation into `course`, `classroom`, and `section`.

Used for:
- practical claim that normalization yields the familiar separated schema style
- background for “aim for BCNF, fall back to 3NF when needed”

## OCR and certainty notes

- The PDF text extraction was good enough for headings, page breaks, and most body text.
- Some OCR artifacts appeared around ligatures and spacing.
- Where OCR looked messy, I avoided fine-grained phrasing and kept only claims that were clearly recoverable from the page.
- I did not include direct quotations from the textbook.
