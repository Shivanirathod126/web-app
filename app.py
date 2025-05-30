from flask import Flask, request, render_template

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        first_name = request.form.get("first_name")
        last_name = request.form.get("last_name")
        return f"<h1>Hello, {first_name} {last_name}!</h1><a href='/'>Back</a>"
    return render_template("form.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
