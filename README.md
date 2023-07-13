# Web-3tier-Architecture

테라폼 명령어로 구축을 완료한 후에는

Bastion 호스트로 접근해서
myDB 테이블에 users 테이블을 만들어서 인덱스를 추가해줘야합니다.

myDB -> users 테이블

MySQL [myDB]> create table users (age int, name char(20), PhoneNumber char(20));

[예시]
MySQL [myDB]> insert into users (id, name, passwd) values (11, 'kim', '010-1111-1111');
MySQL [myDB]> insert into users (id, name, passwd) values (22, 'lee', '010-2222-2222');
MySQL [myDB]> insert into users (id, name, passwd) values (33, 'park', '010-3333-3333');


![image](https://github.com/Parksanghyeon97/Web-3tier-Architecture/assets/102512718/a17ce591-87d1-4ae5-9866-5fc3c555e6f7)


그렇지 않을 경우 ALB DNS 주소를 입력했을때 화면에 출력되는 내용이 없어 오류를 발생합니다.

DB 구성이 완료되고 나서 ALB DNS 주소를 입력하면 users 테이블의 select * from users 결과가 출력됩니다.

![image](https://github.com/Parksanghyeon97/Web-3tier-Architecture/assets/102512718/ec1efaba-0d27-4689-9012-0060f436deba)
