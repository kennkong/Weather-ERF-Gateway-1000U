INSERT INTO `records` (stations_id, sid, max_flag, pid, value)
SELECT 55, M.sensorid, 1, MAX(P.id), M.mvalue
FROM packets P JOIN sensorvalues S on P.id = S.id
JOIN (SELECT S.sid AS sensorid, MAX(`value`) AS mvalue
FROM packets P JOIN sensorvalues S ON P.id = S.id
WHERE P.stationid = 55 AND S.sid IN (2,3,4,5,6,8,10,11,14,15,16)
GROUP BY 1) M on S.sid = M.sensorid
WHERE S.value = M.mvalue
AND P.stationid = 55
GROUP BY 1, 2, 3, 5	

INSERT INTO `records` (stations_id, sid, max_flag, pid, value)
SELECT 55, M.sensorid, 0, MAX(P.id), M.mvalue
FROM packets P JOIN sensorvalues S on P.id = S.id
JOIN (SELECT S.sid AS sensorid, MIN(`value`) AS mvalue
FROM packets P JOIN sensorvalues S ON P.id = S.id
WHERE P.stationid = 55 AND S.sid IN (2,3,4,5,6,14,16)
GROUP BY 1) M on S.sid = M.sensorid
WHERE S.value = M.mvalue
AND P.stationid = 55
GROUP BY 1, 2, 3, 5	
