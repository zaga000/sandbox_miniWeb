import os
from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import func

app = Flask(__name__)


DB_USER = os.getenv('DB_USER', 'admin')
DB_PASS = os.getenv('DB_PASSWORD', 'password123')
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_NAME = os.getenv('DB_NAME', 'quotedb')

app.config['SQLALCHEMY_DATABASE_URI'] = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

class Quote(db.Model):
    __tablename__ = 'quotes'
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.String(500), nullable=False)
    author = db.Column(db.String(100))

    def __repr__(self):
        return f'<Quote {self.text}>'
    
@app.route('/')
def index():
    git_sha = os.getenv('GIT_SHA', 'dev-version')

    random_quote = Quote.query.order_by(func.rand()).first()
    
    if not random_quote:
        content = "Database is empty. Please add some quotes!"
        author = "Systen"
    else:
        content = random_quote.text
        author = random_quote.author

    return render_template('index.html', quote=content, author=author, sha=git_sha)

@app.route('/health')
def health():
    try:
        db.session.execute('SELECT 1')
        return {"status": "ok", "db": "connected"}, 200
    except Exception as e:
        return {"status": "error", "message": str(e)}, 500
    

def setup_database():
    db.create_all()

    if Quote.query.count() == 0:
        print("Database is empty. Populating with initial quotes...")
        
        initial_quotes = [
            Quote(text="Cloud is just someone else's computer", author="Unknown"),
            Quote(text="It works on my machine", author="Every Dev"),
            Quote(text="Keep coding, keep learning", author="Junior"),
            Quote(text="The best way to predict the future is to invent it", author="Alan Kay")
        ]
        
        db.session.add_all(initial_quotes)
        db.session.commit()
        print("Database has been populated with initial quotes.")
    else:
        print("Database already is populated. Skiping initialization.")

if __name__ == '__main__':
    with app.app_context():
        setup_database()
    
    app.run(host='0.0.0.0', port=80)