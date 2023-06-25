# tomcat-docker-public

tomcat(java)/apache/mysql稼働環境

maven開発環境(Springboot対応)

## コンテナ構成

apache(httpd)
tomcat(Ver.9)
mysql(5.7.33)
adminer
maven開発(openjdk11)

## コンテナ展開方法

```bash
git clone https://github.com/naritomo08/tomcat-docker-public.git
cd tomcat-docker-public
docker-compose up -d
```

## tomcatプロジェクトURL

```bash
http://localhost:8080/warファイル名/
```

## apache(httpd)プロジェクトURL

```bash
http://localhost/warファイル名/
```

## adminer(DB管理ツール)

http://localhost:8081

* ログイン情報
  - サーバ: mysql_db
  - ユーザ名: tomcat
  - パスワード: password
  - データベース: tomcatdb

## maven(java)開発環境

### コンテナログイン

```bash
docker-compose exec maven /bin/bash
```

### tomcatプロジェクト作成

```bash
mvn archetype:generate -DgroupId=com.example -DartifactId=my-tomcat-app -Dversion=1.0-SNAPSHOT -DarchetypeArtifactId=maven-archetype-webapp

* "my-tomcat-app"がプロジェクト名(warファイル名)となる。
```

作成された"my-tomcat-app"内でサーブレットを作成する。

javaフォルダ内でjavaソースファイル/webapp内にJSPファイルを置く。

プロジェクト作成後以下の設定を実施して、mavenビルドできるようにすること。

```bash
cd {プロジェクト名}
vi pom.xml

以下の内容を<dependencies>~</dependencies>内に追記する。

    <dependency>
      <groupId>javax.servlet</groupId>
      <artifactId>javax.servlet-api</artifactId>
      <version>4.0.1</version>
      <scope>provided</scope>
    </dependency>
    <dependency>
      <groupId>javax.servlet.jsp</groupId>
      <artifactId>javax.servlet.jsp-api</artifactId>
      <version>2.3.3</version>
      <scope>provided</scope>
    </dependency>

以下の内容を<build>~</build>内に追記する。

    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.8.1</version>
        <configuration>
          <source>11</source>
          <target>11</target>
        </configuration>
      </plugin>
    </plugins>
```

### tomcatサーブレットサンプル

以下のファイルを作成する。

```bash
mkdir src/main/java
vi src/main/java/HelloServlet.java

package com.example;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class HelloServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        response.getWriter().println("<h1>Hello, World!</h1>");
    }
}
```

```bash
vi src/main/webapp/WEB-INF

以下の内容を<web-app>~</web-app>内に追記する。

  <servlet>
    <servlet-name>HelloServlet</servlet-name>
    <servlet-class>com.example.HelloServlet</servlet-class>
  </servlet>
  <servlet-mapping>
    <servlet-name>HelloServlet</servlet-name>
    <url-pattern>/helloservlet</url-pattern>
  </servlet-mapping>
```

### mavenビルド

```bash
mvn clean package

* targetフォルダ内でwarファイルが作成されること。
コンテナから抜ける。
```

### tomcatビルド

tomcat-docker-public/webapps内にmavenビルドで作成したwarファイルを置く。

以下のURLでサーブレット参照できること。

http://localhost:8080/{プロジェクト名}/{サーブレット名}

## apache(httpd)

### apacheからのtomcatサイト参照

以下の操作を実施する。

```bash
vi tomcat-docker-public/httpd.conf

最後の行に以下の記載を実施。
ProxyPass /my-tomcat-app http://tomcat:8080/my-tomcat-app
ProxyPassReverse /my-tomcat-app http://tomcat:8080/my-tomcat-app

* "my-tomcat-app"(プロジェクト名)について、必要に応じて変更すること。
```

コンテナ再起動を実施する。
```bash
docker-compose stop
docker-compose up -d
```

以下のURLでサーブレット参照できること。

http://localhost/{プロジェクト名}/{サーブレット名}
