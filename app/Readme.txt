Autores: 
    *   Galindo Añel Vianey Jerusalen
    *   García Aguilar Luis Alberto
    *   Granillo Alatorre Ricardo GUillermo

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

La aplicación aquí contenida pretende hacer un análisis a los datos de 
sobrevivientes del titanic presentando los resultados de manera gráfica e interactiva. 
Adicionalmente se incluye una administración básica para los datos y su análisis.

1. Modulos

La aplicación cuenta con los siguientes módulos:


    Inicialmente al cargar la aplicación, se carga la BD titanic.csv en una base de datos postgres 
    y se entrena un modelo (RandomForestClassifier) que permite realizar predicciones de sobrevivencia


    a.  Modelado y predicción

        *   La pestaña 1 de la interfaz muestra un formulario con el cual se puede predecir 
            la probabilidad de haber sovrevivido al titanic

            -   La predicción se realiza mediante el archivo model.sav el cual almacena un 
                modelo, implementado en python,previamente entrenado (al cargar la aplicación) con 
                los datos de la BD
            
        *   En la misma pestaña encontramos un botón que permite reentrenar el modelo de predicción

            -   EL botón manda a llamar una API mediante un metodo REST, implementado en python,
                para reentrenar el modelo y actualizar el archivo model.sav y dejarlo listo para 
                futuras predicciones


    b.  Consola de administración de Base de Datos

        *   En la segunda pestaña encontramos un data table, implementado en R, que muestra los registros de la BD de titanic

            -   Podemos realizar modificaciones directas a la BD mediante esta consola de administración.
            
            -   La posibles operaciónes CRUD son:
                
                --  Leer y buscar datos en la BD
                --  Agregar un nuevo pasajero del titanic
                --  Editar un pasajero 
                --  Eliminar un pasajero

    c.  Visualización y gráficos interactivos

        *   Contamos con una matriz de correlaciones para las variables de la BD

        *   Contamos con una gráfica interactiva, implementada en R, que muestra los sobrevivientes del titanic de acuerdo actualizar
            la opción elegida en un combo box (opciones: sexo, clase y edad de los pasajeros)

2. COmponentes

    a.  Base de datos

        *  BD postgres que se monta al levantar la aplicación y que contiene datos de pasajeros del titanic

    b.  API

        *  Desarrollada en python permite Acceder a metodos REST para efectuar predicción y reentrenamiento del 
        modelo mediante datos extraidos de la BD

    c.  Aplicación

        * Implementada mediante una shiny App en R permite visualizar la UI y consumir los servicios de la API
    
    d.  Dockers

        * Permite empaquetar nuestros componentes para poder desplegar el ambiente de manera integra en cualquier 
        máquina

