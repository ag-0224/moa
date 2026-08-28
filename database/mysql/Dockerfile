# database/mysql/Dockerfile
# MOA 로컬 MySQL 개발 환경.
# MYSQL_ROOT_PASSWORD 등 자격 증명은 이미지에 절대 포함하지 않고,
# docker-compose.yml의 environment(.env 파일)로 실행 시점에 주입한다.
FROM mysql:8.0.34

ENV TZ=Asia/Seoul

# 초기 DB 구성 스크립트 및 커스텀 설정 반영
COPY ./scripts/ /docker-entrypoint-initdb.d/
COPY ./my.cnf /etc/my.cnf

CMD ["mysqld", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci"]

EXPOSE 3306
