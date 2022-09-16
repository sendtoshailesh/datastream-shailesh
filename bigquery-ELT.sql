create table `shailesh-1.debezium.account_final` as select after.user_id,after.username,after.password from `shailesh-1.debezium.accounts_next_stage` ;
create table `shailesh-1.debezium.account_stage` as select user_id,username,password from `shailesh-1.debezium.account_final` where 1=2;


SELECT * FROM `shailesh-1.debezium.accounts` WHERE (before.user_id=109 or after.user_id=109) 
and (ts_ms=(select max(ts_ms) FROM `shailesh-1.debezium.accounts` WHERE (before.user_id=109 or after.user_id=109)));


select TIMESTAMP_MILLIS(ts_ms) FROM `shailesh-1.debezium.accounts` WHERE (before.user_id=109 or after.user_id=109) ;

SELECT * FROM `shailesh-1.debezium.accounts` WHERE (before.user_id=109 or after.user_id=109) 
and TIMESTAMP_MILLIS(ts_ms) between TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL -60 MINUTE) and CURRENT_TIMESTAMP();


truncate table `shailesh-1.debezium.account_final` ;
insert `shailesh-1.debezium.account_final` 
SELECT after.user_id,after.username,after.password 
FROM `shailesh-1.debezium.accounts_next_stage` b WHERE 
(ts_ms=(select max(ts_ms) FROM `shailesh-1.debezium.accounts_next_stage` a where a.after.user_id=b.after.user_id));

select * from `shailesh-1.debezium.account_final`;


truncate table `shailesh-1.debezium.account_stage`;

SELECT after.user_id,after.username,after.password FROM `shailesh-1.debezium.accounts` 
WHERE TIMESTAMP_MILLIS(ts_ms) between TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL -60 MINUTE) and CURRENT_TIMESTAMP();


MERGE `shailesh-1.debezium.account_final`  T
USING `shailesh-1.debezium.accounts_staging`  S
ON T.user_id = S.after.user_id
WHEN MATCHED THEN
  UPDATE SET T.username=S.after.username,T.password=S.after.password
WHEN NOT MATCHED THEN
  INSERT (user_id,username,password)
        VALUES(S.after.user_id,S.after.username,S.after.password)


