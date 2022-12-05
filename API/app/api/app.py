from flask import Flask, request
import json
import psycopg2
import psycopg2.extras
import os
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
import pickle

# Estructura del uri:
# "motor://user:password@host:port/database"
database_uri = f'postgresql://{os.environ["PGUSR"]}:{os.environ["PGPASS"]}@{os.environ["PGHOST"]}:5432/{os.environ["PGDB"]}'

app = Flask(__name__)
conn = psycopg2.connect(database_uri)

@app.route('/getProbaSurvive',methods=["POST"])
def calcProb():
    params = json.loads(request.data)
    
    rf_model_saved = pickle.load(open('app/model.sav', 'rb'))
    
    array = np.array([[params[0]["age"],params[0]["sex"],params[0]["class"],params[0]["companion"],params[0]["children"]]])
    y_test = pd.DataFrame(array,columns = ['Age','Sex','Pclass','Siblings/Spouses Aboard','Parents/Children Aboard'])


    proba = rf_model_saved.predict_proba(y_test)[0,1]
    
    return str(proba.astype(float).round(6))


@app.route('/entrena', methods=['POST'])
def entrena():
    # Load dataset
    params = json.loads(request.data)
    option = params[0]["option"]

    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    user_id = request.args.get("id")
    cur.execute(f"select age,sex,pclass,siblings_Spouses_Aboard, parents_Children_Aboard,survived from titanic")
    df = pd.DataFrame(cur.fetchall(),columns=['Age','Sex','Pclass','Siblings/Spouses Aboard','Parents/Children Aboard','Survived'])
    cur.close()

    df.Sex = df.Sex.map(lambda x: 0 if x=="male" else 1)

    df_train, df_test = train_test_split(df, test_size=0.2)
   
    # Extract data as matrices
    x_train = df_train[['Age','Sex','Pclass','Siblings/Spouses Aboard','Parents/Children Aboard']]
    y_train = df_train[['Survived']]
    
    rf_model = RandomForestClassifier(random_state=0).fit(x_train, y_train)
    
    # save the model to disk
    filename = 'app/model.sav'
    pickle.dump(rf_model, open(filename, 'wb'))

    if(option=="entrenar"):
        return "Modelo entrenado"
    else:
        return "Modelo re-entrenado"
    


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=8080)
