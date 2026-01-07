# os is used for the database connection
# psycopg2 is used for the database connection (PostgreSQL)
# flask is used for the webserver
# dotenv is used for environment variables. Like the database information.
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from flask import Flask, jsonify, abort
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)

# Database connection using the .env file
def get_db_connection():
    conn = psycopg2.connect(
        host=os.environ.get("DB_HOST"),
        database=os.environ.get("DB_NAME"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASSWORD"),
        port=os.environ.get("DB_PORT"),
    )
    conn.cursor_factory = RealDictCursor
    return conn

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

# Route to get the characters of a user. Not all character information is loaded, just for an overview
@app.route('/api/users/<int:user_id>/characters')
def get_user_characters(user_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute('SELECT id FROM users WHERE id = %s;', (user_id,))
        if cur.fetchone() is None:
            abort(404, description="User not found")

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
        cur.execute(query, (user_id,))
        characters = cur.fetchall()
        cur.close()

        return jsonify(characters)

    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Server Error: {error}")
        return jsonify({"status": "error", "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# Fetch full character sheet for a giving character. Should only be run if the user is owner of the character
@app.route('/api/characters/<int:character_id>')
def get_character_sheet(character_id):
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
            WHERE c.id = %s
            GROUP BY c.id, r.name;
        """
        cur.execute(query_char, (character_id,))
        character = cur.fetchone()

        if character is None:
            abort(404, description="Character not found")

        # Inventory, feats, skills and spells
        cur.execute("SELECT * FROM view_character_inventory WHERE character_id = %s", (character_id,))
        character['inventory'] = cur.fetchall()

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

# Fetch all items for a short, general overview
@app.route('/api/items')
def get_items():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, name, item_type, price, weight, book_name FROM view_item_details ORDER BY name;")
        items = cur.fetchall()
        return jsonify(items)
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

# Fetch all spells for a short, general overview
@app.route('/api/spells')
def get_spells():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, name, school, subschool, book_name FROM view_spell_details ORDER BY name;")
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
        # Exclude search_vector to ensure JSON serializability
        query = """
            SELECT id, name, school, subschool, descriptors, casting_time, spell_range, 
                   target, duration, saving_throw, spell_resistance, description, 
                   source_id, has_verbal_component, has_somatic_component, 
                   has_material_component, has_focus_component, has_xp_component, 
                   has_divine_focus_component, has_expensive_component, 
                   material_focus_description, gp_cost, xp_cost, page, book_name, book_abbr
            FROM view_spell_details 
            WHERE id = %s;
        """
        cur.execute(query, (spell_id,))
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

#Fetch all feats for a short, general overview
@app.route('/api/feats')
def get_feats():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, name, feat_type, book_name FROM view_feat_details ORDER BY name;")
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

# Fetch all monsters for a short, general overview. DM only
@app.route('/api/monsters')
def get_monsters():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, name, type, cr_text, book_name FROM view_monster_details ORDER BY name;")
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
def get_monster_detail(monster_id):
    conn = None
    try:
        conn = get_db_connection()
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

# Fetch all rules for a short, general overview
@app.route('/api/rules')
def get_rules():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, name, category, subcategory FROM rules ORDER BY name;")
        rules = cur.fetchall()
        return jsonify(rules)
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
        # Exclude search_vector and timestamps
        cur.execute("SELECT id, name, category, subcategory, description FROM rules WHERE id = %s;", (rule_id,))
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
        # Explicitly select columns to avoid potential issues with timestamps or other non-JSON types
        cur.execute("SELECT id, name, key_attribute, trained_only, armor_check_penalty, description, source_id FROM skills WHERE id = %s;", (skill_id,))
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
        cur = conn.cursor()
        cur.execute("SELECT id, name FROM conditions ORDER BY name;")
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
        # Exclude search_vector
        cur.execute("SELECT id, name, description FROM conditions WHERE id = %s;", (condition_id,))
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