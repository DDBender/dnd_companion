# 3.5e Database Companion
App, server and database toolkit for players and DMs. This project provides a robust framework for managing 3.5e campaigns, pre-loaded with official SRD content.
**Note:** This repository contains only Open Game Content (SRD). Private campaign data or non-SRD content must be added manually by the user. The SRD data will be provided as separate sql files.

## Project Purpose
This is a personal passion project built for fun and learning. My goal is to combine my interest in tabletop RPGs with a modern tech stack (Flutter, Python, PostgreSQL) and explore the capabilities of AI-assisted development.

## Built With
- **AI Assistance:** Database data and boilerplate server logic were retrieved co-developed with **Gemini Code Assist**. All generated code has been audited and verified for accuracy.
- **Frontend (planned):** Flutter (Dart) — Cross-platform UI for Android, iOS, and Web.
- **Backend:** Python 
    * **Framework:** Flask (REST API)
    * **WSGI Server (planned):** Gunicorn (Production-grade deployment)
- **Database:** PostgreSQL — Relational storage for complex 3.5e SRD schemas.

## Guide
### Database
The database needs to have a few roles accessible before importing
- dnd_player_role (for players, have access to their adventurers, no access to users or monsters)
- dnd_gm_role (for the gm, with access to monsters)
- dnd_auth_role (for the admin, access to users)
The **.env** file holds the database configuration for the webserver

### Webserver
If you want to host it on a server, make sure to have the following dependencies installed via pip (preferrably using a virtual environment):
`pip install psycopg2-binary Flask python-dotenv PyJWT`
Don't forget to configure the .env file with the correct data for the db and your secret key for the webserver!

### App
The app should be configured to use the correct server to connect to using its .env file

## Licensing & Legal

This project is a hybrid of software and gaming content, governed by the following licenses:

### 1. Software License
The **source code**, server logic, and database schema are licensed under the **GNU General Public License v3.0 (GPLv3)**. See the `LICENSE` file for the full text.

### 2. Game Content License
All game mechanics, statistics, and descriptions derived from the 3.5e System Reference Document (SRD) are used under the **Open Game License v1.0a**. The full text of the OGL and the mandatory **Section 15 Copyright Notice** can be found in [LEGAL.md](./LEGAL.md).

### 3. Product Identity
The following items are hereby identified as **Product Identity** as defined in the Open Game License 1.0a, Section 1(e), and are not Open Content:
* The name **3.5e Database Companion**.
* All custom logos, icons, and user interface design elements.
* All unique documentation not derived from the SRD.

### 4. Open Game Content
Except for material designated as Product Identity (see above), the game mechanics of this product (spells, feats, monsters, etc.) are Open Game Content.
