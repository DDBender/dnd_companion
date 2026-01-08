"""
3.5e Database Companion
Copyright (C) 2026 Daniel Bender

-----------------------------------------------------------------------
AI DISCLOSURE: 
This file was developed with the assistance of Gemini Code Assist. 
AI-generated logic and boilerplate have been reviewed, refined, and 
verified by the human author for accuracy and project integration.
-----------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
"""

# os is used for the database connection
# psycopg2 is used for the database connection (PostgreSQL)
# flask is used for the webserver
# dotenv is used for environment variables. Like the database information.
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from flask import Flask, jsonify, abort, request
from dotenv import load_dotenv
import jwt
import datetime
from functools import wraps
from werkzeug.security import check_password_hash, generate_password_hash

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get("SECRET_KEY", "your_secret_key")

# Database connection using the .env file
def get_db_connection(db_role='player'):
    # Select credentials based on the requested database role
    if db_role == 'dm':
        user = os.environ.get("DB_GM_USER", os.environ.get("DB_USER"))
        password = os.environ.get("DB_GM_PASSWORD", os.environ.get("DB_PASSWORD"))
    elif db_role == 'auth':
        user = os.environ.get("DB_AUTH_USER", os.environ.get("DB_USER"))
        password = os.environ.get("DB_AUTH_PASSWORD", os.environ.get("DB_PASSWORD"))
    else: # default to player
        user = os.environ.get("DB_PLAYER_USER", os.environ.get("DB_USER"))
        password = os.environ.get("DB_PLAYER_PASSWORD", os.environ.get("DB_PASSWORD"))

    conn = psycopg2.connect(
        host=os.environ.get("DB_HOST"),
        database=os.environ.get("DB_NAME"),
        user=user,
        password=password,
        port=os.environ.get("DB_PORT"),
    )
    conn.cursor_factory = RealDictCursor
    return conn

# Decorator for verifying the JWT
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            if auth_header.startswith('Bearer '):
                token = auth_header.split(" ")[1]
        
        if not token:
            return jsonify({'message': 'Token is missing!'}), 401
        
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
            current_user_id = data['user_id']
        except:
            return jsonify({'message': 'Token is invalid!'}), 401
        
        return f(current_user_id, *args, **kwargs)
    
    return decorated

# Decorator for verifying the user is a DM
def dm_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            if auth_header.startswith('Bearer '):
                token = auth_header.split(" ")[1]
        if not token:
            return jsonify({'message': 'Token is missing!'}), 401
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
            if data.get('role') != 'dm':
                return jsonify({'message': 'DM access required'}), 403
        except:
            return jsonify({'message': 'Token is invalid!'}), 401
        return f(*args, **kwargs)
    return decorated

# Root directory. No content yet
@app.route('/')
def index():
    return jsonify({"message": "Welcome to the DnD Compendium API!"})

# Checks database connection reading the number of saved races
@app.route('/api/status')
def db_test():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT count(*) FROM races;')
        race_count = cur.fetchone()['count']
        cur.close()
        return jsonify({"status": "success", "database": "connected", "race_count": race_count})
    except Exception as e:
        print(e)
        return jsonify({"status": "error", "error": str(e)}), 500
    finally:
        if conn:
            conn.close()

# Route for registration
@app.route('/api/register', methods=['POST'])
def register():
    data = request.json
    if not data or not data.get('username') or not data.get('password'):
        return jsonify({'message': 'Username and password are required'}), 400

    username = data.get('username')
    password = data.get('password')
    email = data.get('email')
    role = 'player' # Always register as player. Admin can change later.

    conn = None
    try:
        conn = get_db_connection(db_role='auth')
        cur = conn.cursor()

        # Check if username exists
        cur.execute('SELECT id FROM users WHERE username = %s', (username,))
        if cur.fetchone():
            return jsonify({'message': 'Username already exists'}), 409

        # Check if email exists (if provided)
        if email:
            cur.execute('SELECT id FROM users WHERE email = %s', (email,))
            if cur.fetchone():
                return jsonify({'message': 'Email already exists'}), 409

        hashed_password = generate_password_hash(password)

        cur.execute(
            'INSERT INTO users (username, password_hash, email, role) VALUES (%s, %s, %s, %s) RETURNING id',
            (username, hashed_password, email, role)
        )
        user_id = cur.fetchone()['id']
        conn.commit()

        return jsonify({'message': 'User registered successfully', 'user_id': user_id, 'role': role}), 201

    except (Exception, psycopg2.DatabaseError) as error:
        if conn:
            conn.rollback()
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Route for login
@app.route('/api/login', methods=['POST'])
def login():
    auth = request.json
    if not auth or not auth.get('username') or not auth.get('password'):
        return jsonify({'message': 'Could not verify', 'WWW-Authenticate': 'Basic realm="Login required!"'}), 401

    conn = None
    try:
        conn = get_db_connection(db_role='auth')
        cur = conn.cursor()
        cur.execute('SELECT * FROM users WHERE username = %s', (auth.get('username'),))
        user = cur.fetchone()
        cur.close()

        if not user:
             return jsonify({'message': 'User not found'}), 401

        if check_password_hash(user['password_hash'], auth.get('password')):
             token = jwt.encode({
                 'user_id': user['id'],
                 'role': user['role'],
                 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
             }, app.config['SECRET_KEY'], algorithm="HS256")
             return jsonify({'token': token, 'role': user['role'], 'user_id': user['id']})

        return jsonify({'message': 'Could not verify'}), 401
    except Exception as e:
        print(e)
        return jsonify({"status": "error", "error": str(e)}), 500
    finally:
        if conn:
            conn.close()

# Route to get the characters of a user. Not all character information is loaded, just for an overview
@app.route('/api/characters', methods=['GET'])
@token_required
def get_user_characters(current_user_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Join characters, race and class info for the characters
        query = """
            SELECT
                c.*,
                r.name as race_name,
                json_agg(json_build_object('class', cl.name, 'level', cc.class_level))
                    FILTER (WHERE cl.id IS NOT NULL) as classes
            FROM characters c
            JOIN races r ON c.race_id = r.id
            LEFT JOIN character_classes cc ON c.id = cc.character_id
            LEFT JOIN classes cl ON cc.class_id = cl.id
            WHERE c.user_id = %s
            GROUP BY c.id, r.name;
        """
        cur.execute(query, (current_user_id,))
        characters = cur.fetchall()
        cur.close()

        return jsonify(characters)

    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Create a new character
@app.route('/api/characters', methods=['POST'])
@token_required
def create_character(current_user_id):
    data = request.json
    # Basic validation
    if not data or not data.get('name') or not data.get('race_id'):
        return jsonify({'message': 'Name and Race ID are required'}), 400

    conn = None
    try:
        conn = get_db_connection() # Default role 'player' has write access
        cur = conn.cursor()

        # Insert character
        query = """
            INSERT INTO characters (
                user_id, name, race_id, alignment, gender, age, height, weight, description,
                strength, dexterity, constitution, intelligence, wisdom, charisma,
                hit_points_max, hit_points_current, experience_points, money_gp
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s
            ) RETURNING id;
        """
        cur.execute(query, (
            current_user_id,
            data.get('name'),
            data.get('race_id'),
            data.get('alignment'),
            data.get('gender'),
            data.get('age'),
            data.get('height'),
            data.get('weight'),
            data.get('description'),
            data.get('strength', 10),
            data.get('dexterity', 10),
            data.get('constitution', 10),
            data.get('intelligence', 10),
            data.get('wisdom', 10),
            data.get('charisma', 10),
            data.get('hit_points_max', 0),
            data.get('hit_points_current', 0),
            data.get('experience_points', 0),
            data.get('money_gp', 0)
        ))
        character_id = cur.fetchone()['id']

        # Insert classes if present
        # Expecting list of dicts: [{"class_id": 1, "level": 1}, ...]
        classes = data.get('classes', [])
        if classes:
            class_query = """
                INSERT INTO character_classes (character_id, class_id, class_level)
                VALUES (%s, %s, %s)
            """
            for c in classes:
                c_id = c.get('class_id')
                level = c.get('level')
                if c_id and level:
                    cur.execute(class_query, (character_id, c_id, level))

        conn.commit()
        return jsonify({'message': 'Character created successfully', 'character_id': character_id}), 201

    except (Exception, psycopg2.DatabaseError) as error:
        if conn:
            conn.rollback()
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Update an existing character
@app.route('/api/characters/<int:character_id>', methods=['PUT'])
@token_required
def update_character(current_user_id, character_id):
    data = request.json
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Check ownership
        cur.execute("SELECT user_id FROM characters WHERE id = %s", (character_id,))
        char = cur.fetchone()
        if not char:
            return jsonify({'message': 'Character not found'}), 404
        if char['user_id'] != current_user_id:
            return jsonify({'message': 'Unauthorized'}), 403

        # Build update query dynamically
        fields = []
        values = []
        # List of allowed columns to update
        allowed = ['name', 'alignment', 'gender', 'age', 'height', 'weight', 'description',
                   'strength', 'dexterity', 'constitution', 'intelligence', 'wisdom', 'charisma',
                   'hit_points_max', 'hit_points_current', 'experience_points', 'money_gp']
        
        for key, val in data.items():
            if key in allowed:
                fields.append(f"{key} = %s")
                values.append(val)
        
        if not fields:
            return jsonify({'message': 'No valid fields provided for update'}), 400
            
        values.append(character_id)
        query = f"UPDATE characters SET {', '.join(fields)} WHERE id = %s"
        cur.execute(query, tuple(values))
        conn.commit()
        
        return jsonify({'message': 'Character updated successfully'}), 200
    except (Exception, psycopg2.DatabaseError) as error:
        if conn:
            conn.rollback()
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Add an item to character inventory
@app.route('/api/characters/<int:character_id>/inventory', methods=['POST'])
@token_required
def add_character_item(current_user_id, character_id):
    data = request.json
    if not data or not data.get('item_id'):
        return jsonify({'message': 'Item ID is required'}), 400
    
    item_id = data.get('item_id')
    quantity = data.get('quantity', 1)
    
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Check ownership
        cur.execute("SELECT user_id FROM characters WHERE id = %s", (character_id,))
        char = cur.fetchone()
        if not char:
            return jsonify({'message': 'Character not found'}), 404
        if char['user_id'] != current_user_id:
            return jsonify({'message': 'Unauthorized'}), 403
            
        # Determine item type to insert into correct table
        cur.execute("""
            SELECT it.name 
            FROM items i 
            JOIN item_types it ON i.item_type_id = it.id 
            WHERE i.id = %s
        """, (item_id,))
        result = cur.fetchone()
        
        if not result:
            return jsonify({'message': 'Item not found'}), 404
            
        item_type = result['name'].lower()
        
        if item_type == 'weapon':
            cur.execute("INSERT INTO character_weapons (character_id, item_id, quantity) VALUES (%s, %s, %s)", (character_id, item_id, quantity))
        elif item_type == 'armor':
            cur.execute("INSERT INTO character_armor (character_id, item_id, quantity) VALUES (%s, %s, %s)", (character_id, item_id, quantity))
        else:
            cur.execute("INSERT INTO character_gear (character_id, item_id, quantity) VALUES (%s, %s, %s)", (character_id, item_id, quantity))
            
        conn.commit()
        
        return jsonify({'message': 'Item added to inventory'}), 201
    except (Exception, psycopg2.DatabaseError) as error:
        if conn:
            conn.rollback()
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Add a feat to character
@app.route('/api/characters/<int:character_id>/feats', methods=['POST'])
@token_required
def add_character_feat(current_user_id, character_id):
    data = request.json
    if not data or not data.get('feat_id'):
        return jsonify({'message': 'Feat ID is required'}), 400
    
    feat_id = data.get('feat_id')
    note = data.get('note')
    
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Check ownership
        cur.execute("SELECT user_id FROM characters WHERE id = %s", (character_id,))
        char = cur.fetchone()
        if not char:
            return jsonify({'message': 'Character not found'}), 404
        if char['user_id'] != current_user_id:
            return jsonify({'message': 'Unauthorized'}), 403
            
        # Insert feat
        cur.execute("""
            INSERT INTO character_feats (character_id, feat_id, note)
            VALUES (%s, %s, %s)
        """, (character_id, feat_id, note))
        conn.commit()
        
        return jsonify({'message': 'Feat added to character'}), 201
    except (Exception, psycopg2.DatabaseError) as error:
        if conn:
            conn.rollback()
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Add/Update a skill for character
@app.route('/api/characters/<int:character_id>/skills', methods=['POST'])
@token_required
def add_character_skill(current_user_id, character_id):
    data = request.json
    if not data or not data.get('skill_id') or data.get('ranks') is None:
        return jsonify({'message': 'Skill ID and Ranks are required'}), 400
    
    skill_id = data.get('skill_id')
    ranks = data.get('ranks')
    
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Check ownership
        cur.execute("SELECT user_id FROM characters WHERE id = %s", (character_id,))
        char = cur.fetchone()
        if not char:
            return jsonify({'message': 'Character not found'}), 404
        if char['user_id'] != current_user_id:
            return jsonify({'message': 'Unauthorized'}), 403
        
        # Check if skill exists (Upsert logic)
        cur.execute("SELECT id FROM character_skills WHERE character_id = %s AND skill_id = %s", (character_id, skill_id))
        existing_skill = cur.fetchone()
        
        if existing_skill:
            cur.execute("UPDATE character_skills SET ranks = %s WHERE id = %s", (ranks, existing_skill['id']))
        else:
            cur.execute("INSERT INTO character_skills (character_id, skill_id, ranks) VALUES (%s, %s, %s)", (character_id, skill_id, ranks))
            
        conn.commit()
        return jsonify({'message': 'Skill updated successfully'}), 200
    except (Exception, psycopg2.DatabaseError) as error:
        if conn:
            conn.rollback()
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch full character sheet for a giving character. Should only be run if the user is owner of the character
@app.route('/api/characters/<int:character_id>')
@token_required
def get_character_sheet(current_user_id, character_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # 1. Basic character info, race, and classes
        query_char = """
            SELECT
                c.*,
                r.name as race_name,
                json_agg(json_build_object('class', cl.name, 'level', cc.class_level))
                    FILTER (WHERE cl.id IS NOT NULL) as classes
            FROM characters c
            JOIN races r ON c.race_id = r.id
            LEFT JOIN character_classes cc ON c.id = cc.character_id
            LEFT JOIN classes cl ON cc.class_id = cl.id
            WHERE c.id = %s AND c.user_id = %s
            GROUP BY c.id, r.name;
        """
        cur.execute(query_char, (character_id, current_user_id))
        character = cur.fetchone()

        if character is None:
            abort(404, description="Character not found")

        # Inventory split into weapons, armor, and gear
        cur.execute("SELECT * FROM view_character_weapons WHERE character_id = %s", (character_id,))
        character['weapons'] = cur.fetchall()

        cur.execute("SELECT * FROM view_character_armor WHERE character_id = %s", (character_id,))
        character['armor'] = cur.fetchall()

        cur.execute("SELECT * FROM view_character_gear WHERE character_id = %s", (character_id,))
        character['gear'] = cur.fetchall()

        cur.execute("SELECT * FROM view_character_feats WHERE character_id = %s", (character_id,))
        character['feats'] = cur.fetchall()

        cur.execute("SELECT * FROM view_character_skills WHERE character_id = %s", (character_id,))
        character['skills'] = cur.fetchall()

        cur.execute("SELECT * FROM view_character_spells WHERE character_id = %s", (character_id,))
        character['spells'] = cur.fetchall()

        return jsonify(character)

    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch all items for a short, general overview. Can filter category and search for words in name or description
@app.route('/api/items')
def get_items():
    conn = None
    try:
        conn = get_db_connection()
        category = request.args.get('category')
        name = request.args.get('name')
        search = request.args.get('search')

        cur = conn.cursor()
        query = "SELECT id, name, item_type, price, weight, book_name FROM view_item_details"
        filters = []
        params = []

        if category:
            filters.append("item_type = %s")
            params.append(category)
        # Used if looking for a specific name, not in description.
        if name:
            filters.append("name ILIKE %s")
            params.append(f"%{name}%")
        if search:
            filters.append("(name ILIKE %s OR description ILIKE %s)")
            params.append(f"%{search}%")
            params.append(f"%{search}%")

        if filters:
            query += " WHERE " + " AND ".join(filters)
        query += " ORDER BY name;"

        cur.execute(query, tuple(params))
        items = cur.fetchall()
        return jsonify(items)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch all item categories
@app.route('/api/items/categories')
def get_item_categories():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT name FROM item_types ORDER BY name;")
        categories = [row['name'] for row in cur.fetchall()]
        return jsonify(categories)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch the exact details for an item
@app.route('/api/items/<int:item_id>')
def get_item_detail(item_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM view_item_details WHERE id = %s;", (item_id,))
        item = cur.fetchone()
        if item is None:
            abort(404, description="Item not found")
        return jsonify(item)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch all spells for a short, general overview. Can search for words in name or description.
@app.route('/api/spells')
def get_spells():
    conn = None
    try:
        conn = get_db_connection()
        search = request.args.get('search')
        cur = conn.cursor()
        query = "SELECT id, name, school, subschool, book_name FROM view_spell_details"
        params = []
        if search:
            query += " WHERE (name ILIKE %s OR description ILIKE %s)"
            params.append(f"%{search}%")
            params.append(f"%{search}%")
        query += " ORDER BY name;"

        cur.execute(query, tuple(params))
        spells = cur.fetchall()
        return jsonify(spells)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch the exact details for a spell
@app.route('/api/spells/<int:spell_id>')
def get_spell_detail(spell_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM view_spell_details WHERE id = %s;", (spell_id,))
        spell = cur.fetchone()
        if spell is None:
            abort(404, description="Spell not found")
        return jsonify(spell)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

#Fetch all feats for a short, general overview. Can search for words in name, benefit and description
@app.route('/api/feats')
def get_feats():
    conn = None
    try:
        conn = get_db_connection()
        search = request.args.get('search')
        cur = conn.cursor()
        query = "SELECT id, name, feat_type, book_name FROM view_feat_details"
        params = []
        if search:
            query += " WHERE (name ILIKE %s OR benefit ILIKE %s OR description ILIKE %s)"
            params.append(f"%{search}%")
            params.append(f"%{search}%")
            params.append(f"%{search}%")
        query += " ORDER BY name;"

        cur.execute(query, tuple(params))
        feats = cur.fetchall()
        return jsonify(feats)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch the exact details for a feat
@app.route('/api/feats/<int:feat_id>')
def get_feat_detail(feat_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM view_feat_details WHERE id = %s;", (feat_id,))
        feat = cur.fetchone()
        if feat is None:
            abort(404, description="Feat not found")
        return jsonify(feat)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch all monsters for a short, general overview. DM only. Can search for words in name or type.
@app.route('/api/monsters')
@dm_required
def get_monsters():
    conn = None
    try:
        conn = get_db_connection(db_role='dm')
        search = request.args.get('search')
        cur = conn.cursor()
        query = "SELECT id, name, type, cr_text, book_name FROM view_monster_details"
        params = []
        if search:
            query += " WHERE (name ILIKE %s OR type ILIKE %s)"
            params.append(f"%{search}%")
            params.append(f"%{search}%")
        query += " ORDER BY name;"

        cur.execute(query, tuple(params))
        monsters = cur.fetchall()
        return jsonify(monsters)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch the exact details for a monster. DM only
@app.route('/api/monsters/<int:monster_id>')
@dm_required
def get_monster_detail(monster_id):
    conn = None
    try:
        conn = get_db_connection(db_role='dm')
        cur = conn.cursor()
        cur.execute("SELECT * FROM view_monster_details WHERE id = %s;", (monster_id,))
        monster = cur.fetchone()
        if monster is None:
            abort(404, description="Monster not found")
        return jsonify(monster)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch all races for a short, general overview
@app.route('/api/races')
def get_races():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, name, size, type FROM races ORDER BY name;")
        races = cur.fetchall()
        return jsonify(races)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch the exact details for a race
@app.route('/api/races/<int:race_id>')
def get_race_detail(race_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM races WHERE id = %s;", (race_id,))
        race = cur.fetchone()
        if race is None:
            abort(404, description="Race not found")
        return jsonify(race)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch all classes for a short, general overview
@app.route('/api/classes')
def get_classes():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, name, main_attr, dice_type FROM classes ORDER BY name;")
        classes = cur.fetchall()
        return jsonify(classes)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch the exact details for a class
@app.route('/api/classes/<int:class_id>')
def get_class_detail(class_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM classes WHERE id = %s;", (class_id,))
        class_data = cur.fetchone()
        if class_data is None:
            abort(404, description="Class not found")
        return jsonify(class_data)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch all rules for a short, general overview. Can filter by category and search for words in name and description.
@app.route('/api/rules')
def get_rules():
    conn = None
    try:
        conn = get_db_connection()
        category = request.args.get('category')
        name = request.args.get('name')
        search = request.args.get('search')

        cur = conn.cursor()
        query = "SELECT id, name, category, subcategory FROM rules"
        filters = []
        params = []

        if category:
            filters.append("category = %s")
            params.append(category)
        # Used if looking for a specific name, not in description.
        if name:
            filters.append("name ILIKE %s")
            params.append(f"%{name}%")
        if search:
            filters.append("(name ILIKE %s OR description ILIKE %s)")
            params.append(f"%{search}%")
            params.append(f"%{search}%")

        if filters:
            query += " WHERE " + " AND ".join(filters)
        query += " ORDER BY name;"

        cur.execute(query, tuple(params))
        rules = cur.fetchall()
        return jsonify(rules)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch all rule categories
@app.route('/api/rules/categories')
def get_rule_categories():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT DISTINCT category FROM rules ORDER BY category;")
        categories = [row['category'] for row in cur.fetchall()]
        return jsonify(categories)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch the exact details for a rule
@app.route('/api/rules/<int:rule_id>')
def get_rule_detail(rule_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM rules WHERE id = %s;", (rule_id,))
        rule = cur.fetchone()
        if rule is None:
            abort(404, description="Rule not found")
        return jsonify(rule)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch all skills for a short, general overview
@app.route('/api/skills')
def get_skills():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, name, key_attribute, trained_only, armor_check_penalty FROM skills ORDER BY name;")
        skills = cur.fetchall()
        return jsonify(skills)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch the exact details for a skill
@app.route('/api/skills/<int:skill_id>')
def get_skill_detail(skill_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM skills WHERE id = %s;", (skill_id,))
        skill = cur.fetchone()
        if skill is None:
            abort(404, description="Skill not found")
        return jsonify(skill)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch all conditions for a short, general overview
@app.route('/api/conditions')
def get_conditions():
    conn = None
    try:
        conn = get_db_connection()
        search = request.args.get('search')
        cur = conn.cursor()
        query = "SELECT id, name FROM conditions"
        params = []
        if search:
            query += " WHERE (name ILIKE %s OR description ILIKE %s)"
            params.append(f"%{search}%")
            params.append(f"%{search}%")
        query += " ORDER BY name;"

        cur.execute(query, tuple(params))
        conditions = cur.fetchall()
        return jsonify(conditions)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch the exact details for a condition
@app.route('/api/conditions/<int:condition_id>')
def get_condition_detail(condition_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM conditions WHERE id = %s;", (condition_id,))
        condition = cur.fetchone()
        if condition is None:
            abort(404, description="Condition not found")
        return jsonify(condition)
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)