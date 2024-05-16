/*
Find the messages sent between two persons per day.
*/
CREATE TABLE SUBSCRIBER (
 SMS_DATE DATE ,
 SENDER VARCHAR(20) ,
 RECEIVER VARCHAR(20) ,
 SMS_NO INT
);

INSERT INTO SUBSCRIBER VALUES ('2020-4-1', 'Avinash', 'Vibhor',10);
INSERT INTO SUBSCRIBER VALUES ('2020-4-1', 'Vibhor', 'Avinash',20);
INSERT INTO SUBSCRIBER VALUES ('2020-4-1', 'Avinash', 'Pawan',30);
INSERT INTO SUBSCRIBER VALUES ('2020-4-1', 'Pawan', 'Avinash',20);
INSERT INTO SUBSCRIBER VALUES ('2020-4-1', 'Vibhor', 'Pawan',5);
INSERT INTO SUBSCRIBER VALUES ('2020-4-1', 'Pawan', 'Vibhor',8);
INSERT INTO SUBSCRIBER VALUES ('2020-4-1', 'Vibhor', 'Deepak',50);
INSERT INTO SUBSCRIBER VALUES ('2020-4-2', 'Avinash', 'Vibhor',1);
INSERT INTO SUBSCRIBER VALUES ('2020-4-2', 'Vibhor', 'Avinash',2);
INSERT INTO SUBSCRIBER VALUES ('2020-4-2', 'Avinash', 'Pawan',3);
INSERT INTO SUBSCRIBER VALUES ('2020-4-2', 'Pawan', 'Avinash',2);
INSERT INTO SUBSCRIBER VALUES ('2020-4-2', 'Vibhor', 'Pawan',5);
INSERT INTO SUBSCRIBER VALUES ('2020-4-2', 'Pawan', 'Vibhor',8);
INSERT INTO SUBSCRIBER VALUES ('2020-4-2', 'Vibhor', 'Deepak',5);


# Approach 1 : Need to remove duplicate after this approach
SELECT A.SMS_DATE, A.SENDER AS PERSON_1 ,A.RECEIVER AS PERSON_2,A.SMS_NO+B.SMS_NO AS MSG_NUM  FROM SUBSCRIBER A 
INNER JOIN SUBSCRIBER B ON A.SENDER=B.RECEIVER AND B.SENDER=A.RECEIVER;

# Approach 2 : Swap columns values for sender receiver 
SELECT SMS_DATE,PERSON_1,PERSON_2,SUM(SMS_NO) AS MSG_COUNT FROM(
SELECT SMS_DATE, CASE WHEN SENDER<RECEIVER THEN SENDER ELSE RECEIVER END AS PERSON_1 ,
CASE WHEN SENDER>RECEIVER THEN SENDER ELSE RECEIVER END AS PERSON_2 ,SMS_NO
FROM SUBSCRIBER) A GROUP BY SMS_DATE , PERSON_1, PERSON_2