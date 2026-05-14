# PROJECT REQUIREMENTS
The present document will specify different project requirements, the ones which are not specified on its guidelines. 

## Domain assumptions
The following assumptions follow design decisions which will clarify those spots where the project guidelines are ambiguous. The assumptions are an essential design part of the project, as they will lead the design decisions troughout it.

1. User-player relationship 1:N [One user could have 1+ player identities]
2. Player-Game relationship N:M [One player could participate in many games, however, a single game session could have many players]
3. Game-Map relationship 1:1 [One game can only occur in one single map at a time]
4. User could revoke consent at any time, if that does happen, every associated record will be unlinked from the 'User' values, keeping an anonymized record.
5. Distance between users are calculted using euclidean distance (√((x2-x1)² + (y2-y1)²)). Therefore, player proximity will materialize when euclidean distance is <=300 units.
6. BANGS will be the UX instrument for analysis.
7. Tics will start counting from 1.
8. Both health and armor will have max values of 200. Health should be in a 0-100 range. However, it can go above 100 using special items. Armor standard range is 0-200. As ammo values fluctuate depending on the gun, its range must be >= 0; superior limit is not established.
9. 'kills' and 'assists' will be aggregated stats for analysis, in both multiplayer and single-player modes. Understand a 'kill' as being the one who directly lowers enemy life down to 0. Understand an 'assist' as collaborating with an enemy 'kill', but not giving the final shot in which enemy's life result as zero. 
10. Linked to assumption #2, the maximum number of players allowed per session is 8.
11. The minimum of tics in which distance will be calculated is of 2 tics (from one tic to another). However, the max value for this is of 35 tics, taking into account doom runs at 35 tics per second. (Distance will be calculated as max each second)


---
## Functional requirements
Functional requirements refer to those actions system must be able to perform, without them, game or telemetry data won't work, making impossible the project developement.

1. The system must save users along their demographic data.
- 1.1. The system must be able to keep telemtry data deleting the user info associated to the telemetry record, in case consent is revoked [See domain assumptions 4th item]
2. The system must be able to save more than one value (for different attributes) at the same time (tic). At least player position (with coordinates x,y), stats (kills, health, armor, ammo, etc.), among other attributes.
3. The system must be able to calculate distance tic-from-tic based on the coordinates of each player, so it could determine player proximity and start functions associated to it in the next k tics range (where k is a number in a range 2 < k < 35, see domain assumtions 11th item).
4. The system must be able to read raw TSV data and process it. Understand proccesing as the procedure in which data is transformed (e.g. converting strings to numeric values) and loading it into SQL final tables, once transforming is done. Malformed records should be identified during this process and be rejected into an error log.
5. The system must store BANGS (Basic needs in games scale) values, which will be a crucial attribute during analytic queries, allowing to detect patterns along players (e.g. are the players who move the most the ones with a higher autonomy level?). BANGS items will be stored individually and linked to a user, not as an aggregated score.

---
## Non-functional requirements
Non-functional requirements refer to those requirements which do not describe which actions system may do, but how might it perform them. They assure system's performance, efficiency, integrity, scalability and reproducibility.

1. Stored data in the system must be consistent with the declared relationships. (e.g. It can not exist a TelemetryEvent record without being associated to a valid game).
2. System must be able to support analytic queries involving +100.000 rows without significant performance degradation. This will be achieved applying appropiate indexing strategies
3. Restrictions (CHECK, NOT NULL, etc.) must be applied at DBS level, applying them only at the frontend will result in an integrity violation
4. System must be able to grow in volume without significant performance degradation. If a game gets longer than expected, there are stored more sessions than expected or any other unexpected escenario, system should support it, not break. 
5. Access to user data should be only granted to authorized users. See ethics and privacy section for more information about this.
6. The complete project schema must be recreatable from a scratch, using a single script.

---
## Ethics and privacy
Ethics and privacy define how user's data and consent to use that data will be managed. The guidelines specified in this section must not be violated, since user's data must be as protected and carefully managed as possible according to Habeas Data legislation in different territories which DOOM could reach. 
> As the project is being developed in Colombia, colombian legislation will be used as a reference for data protection, specifically, law 1581 from 2012, which establishes general provisions for the protection of personal data. Complete information can be consulted by clicking [here](https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=49981)

According to the previous information, the primary provisions (but not the only, following the current legislation) for data privacy during the project are:

1. System requires explicit user's consent to manage and store their data before storing or manipulating any information 
2. The schema will separate structurally demographic data and telemetry data, which will be specified in the E-R diagram of the project.
3. Users could revoke the consent at any time, system must not obstruct that operation and follow the specified procedure to anonymyze any telemetry record associated to that user. See domain assumptions 4th item.
4. Access to user's data must be granted only to anonymyze users with authorization and capabilities to manage those data. This includes the user itself and system admins.
5. It is the user's duty to keep the information stored in the system updated and make sure it is correct and personal information only. We are not responsible for missing, incorrect, outdated or fake information provided by the user.



