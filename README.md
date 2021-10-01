# Container Microsoft SQL Server

Este repositório contem o container do banco de dados Microsoft SQL Server, com scripts que facilitam seu deploy, backup e restore de bases de dados.

## Estrutura de pastas

``` bash
.
├── backups/
├── mssqlbackup/
├── mssqldata/
├── mssqllog/
├── scripts/
│    ├── mssqldatabasebackup.sh
│    └── mssqldatabaserestore.sh
├─── docker-compose.yml
├─── README.md
└─── Makefile
```

## Configurações

* docker-compose.yml
  ```yml
  version: "3.2"
  services:
    mssql:
      container_name: mssql
      restart: always
      image: mcr.microsoft.com/mssql/server:2017-latest
      ports:
        - "1433:1433"
      environment:
        SA_PASSWORD: "<PASSWORD>"
        ACCEPT_EULA: "Y"
      volumes:
        - "./mssqldata:/var/opt/mssql/data"
        - "./mssqllog:/var/opt/mssql/log"
        - "./mssqlbackup:/var/opt/mssql/backup"
  ```
* SA_PASSWORD:  
  * Senha que será criada no banco de dados para o usuário SA.

* volumes:
  * Volumes que são mapeados para fora do container, que contem informações de logs, base da dados e backup. Estas pastas só são criadas quando o container é executado.
  ```yml 
    volumes:
        - "./mssqldata:/var/opt/mssql/data"
        - "./mssqllog:/var/opt/mssql/log"
        - "./mssqlbackup:/var/opt/mssql/backup"
  ```
* Backups (pasta):
  * Quando um backup é criado ele é armazenado dentro de uma pasta "Backups" na raiz do projeto. Esta pasta é criada apenas quando um backup é criado. 

* ./scripts/mssqldatabasebackup.sh:
  * Script responsável por fazer o backup de bases de dados.
  * Para que o script funcione é necessário passar a informação do nome do container e também o nome da base de dados.
    * Primeira forma de funcionar o script:
    ```bash
      Add description of the script functions here.

      Syntax: scriptTemplate [-c|d]
      
      Usage: ./scripts/mssqldatabaserestore.sh -c [container name] -d [database name] -b [backup file name]
      
      options:
      -c     Pass the container name by parameter.
      -d     Pass the name of the database by parameter.
      -f     Pass the name of the backup file by parameter.
    ```
    * Segunda forma de funcionar o script:
    ```bash
      ➜  ./scripts/mssqldatabasebackup.sh                                                           
      Container Name: mssql
      Database Name: master
      Backing up database 'master' from container 'mssql'...
      Password: <PASSWORD>
    ```

## Utilização

OS X & Linux:

Clone repositório
```sh
git clone <this repository>
```

Navegar até a pasta criada
```sh
cd <this repository>
```

Iniciar o Microsoft SQL Server
```sh
make up
```

Parar o Microsoft SQL Server
```sh
make down
```

Visualizar logs do Microsoft SQL Server
```sh
make logs
```

Realizar backup de uma base de dados do Microsoft SQL Server
```sh
make bakup
```

Realizar restore de uma base de dados do Microsoft SQL Server
```sh
make restore
```



