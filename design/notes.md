# notes

1. Versions:
    - Versions are generated when adding vocabulary or subphrases. 
    - Context consumes the queue and updates the version continuously 
    - Context may be asked for the current bitsets under a version at any time (in bulk)
    - Context only publishes a new seed once version is stable - that is, when the queue is empty
    - When workers pull work, they check the version and ask for new context if it is out of date
    - Context delivers context bundled with version so that if version changes after request worker can use the latest
    - Workers never downgrade version
    - Workers publish version when producing results so that the follower can detect old results, and so that other workers can pick up work and recieve notification of new versions
    - Follower asks for all versions and will take batches out of the database. If a remediation is finished it is deleted. If it is still pending the version is updated to latest
    - In practice, version is the count of vocabulary + count of phrases
2. Potential changes
    - consider sharding the results db by sharding the dbq. It may be more convenient to have a service sit between the worker and the dbq for routing
    - consider writing the bitmasks to a file
    - consider not having the versions be up to date but only returning stable versions to prevent worker thrash
    - consider making the workers update their bitsets instead of pulling and overwriting
    - (tricky) - consider making the workers manage the bitsets as a cache
3. Ortho representation
    - make the seed ortho more minimal
    - ensure the seed ortho hash is unique (ideally tied to version number)
    - consider smaller data representations 
    - consider splitting apart the counter from the ortho more thoroughly
    - consider exposing a proprty "jagged" and scheduling jagged orthos higher to avoid the "up" free move