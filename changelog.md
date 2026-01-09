07.01.2026 v0.11
    Database:
        - Switch from tsvector to trigram. Searching for parts of words is used more often than linguistic matches
    
    Webserver:
        - Add more endpoints, search using trigrams -> ILIKE
08.01.2026 v0.12
    Database:
        - Split the character_items table into multiple tables. Differentiation is more logical and easier
            1. character_weapons
            2. character_armor
            3. character_gear

    Webserver: 
        - Add jwt authentication
            - A user will have his user_id in the the jwt. 
            - Requests like getting characters are done by checking the user_id from the jwt.
        - Split database users into roles.
            - Auth user only for login/register. Access to users table.
            - Player user has limited access to tables but can create, update and read his/her own characters
            - DM user has more access to general tables but no access to characters. (Might change later -> Admin role with all access?)
        - Add decorated functions 
            - Check which user is talking to the server
            - Check if user is DM for DM related requests.
        - Add more endpoints for character creation, updating and reading them.

    Environment file:
        - Add roles for database usage to use them in the webserver

09.01.2026 v0.13
    Database:
        - Rename Character to Adventurer (all tables, columns, sequences with character modified)

    Webserver:
        - Rename Character to Adventurer