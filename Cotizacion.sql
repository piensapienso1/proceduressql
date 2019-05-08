DELIMITER ;;

CREATE PROCEDURE `find_AssistanceByStudent`(user_id_variable int(11))
BEGIN

SELECT DISTINCT
  (SELECT count(*) from tutor_db.assitance
    where (tutor_db.assitance.value = 0 and tutor_db.assitance.id_usr_student = user_id_variable))
    as absences,
  (SELECT count(*) from tutor_db.assitance
    where (tutor_db.assitance.value = 2 and tutor_db.assitance.id_usr_student = user_id_variable))
    as presences,
  (SELECT count(*) from tutor_db.assitance
    where (tutor_db.assitance.value = 1 and tutor_db.assitance.id_usr_student = user_id_variable))
    as excuses;


END ;;

CREATE PROCEDURE `find_QualificationByStudent`(course_id int, student_id int, subject_id int)
BEGIN

    SELECT
    CONCAT(U.first_name, ' ', U.last_name) student_name,
    U.user_code,
    SB.name subject_name,
    (select ROUND(AVG(value))
      FROM tutor_db.qualification
      WHERE (id_usr_student = U.user_id AND id_course = SC.id_course AND id_subject = Q.id_subject)) as average_value,
    Q.value,
    Q.test_type,
    Q.test_date

    FROM tutor_db.qualification Q
     LEFT JOIN tutor_db.user U ON Q.id_usr_student =  U.user_id
     LEFT JOIN tutor_db.subject SB ON Q.id_subject = SB.subject_id AND Q.id_usr_student = U.user_id
     LEFT JOIN tutor_db.grade G ON SB.id_grade = G.grade_id
     LEFT JOIN tutor_db.course C ON G.grade_id = C.id_grade
     LEFT JOIN tutor_db.student_course SC ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.teacher_subject TC ON TC.id_subject = SB.subject_id
     WHERE Q.id_course = course_id AND Q.id_usr_student = student_id AND Q.id_subject = subject_id
     GROUP BY U.first_name, U.last_name, U.user_code, average_value, SB.name, Q.value, Q.test_type, Q.test_date;

END

DELIMITER ;;

CREATE PROCEDURE `find_QualificationBySubject`(course_id int, subject_id int)
BEGIN

    SELECT
    CONCAT(U.first_name, ' ', U.last_name) student_name,
    U.user_code,
    S.name subject_name,
    (select ROUND(AVG(value))
      FROM tutor_db.qualification
      WHERE (id_usr_student = U.user_id AND id_course = Q.id_course AND id_subject = Q.id_subject)) as average_value,
    Q.value,
    H.name as school_name,
    H.name as school_id,
    Q.test_type,
    Q.test_date

FROM tutor_db.qualification Q
     LEFT JOIN tutor_db.subject S ON S.subject_id = Q.id_subject
     LEFT JOIN tutor_db.user U ON Q.id_usr_student = U.user_id
     LEFT JOIN tutor_db.user_school US ON US.user_id = U.user_id
     LEFT JOIN tutor_db.school H ON US.school_id = H.school_id

     WHERE Q.id_course = course_id AND Q.id_subject = subject_id
     GROUP BY U.first_name, U.last_name, U.user_code, average_value, S.name, school_name, school_id, Q.value, Q.test_type, Q.test_date;



END ;;

CREATE PROCEDURE `find_QualificationByUserId`(student_id int)
BEGIN

    SELECT DISTINCT
    U.user_id,
    SB.subject_id id_subject,
    CONCAT(U.first_name, ' ', U.last_name) student_name,
    U.user_code,
    SB.name subject_name,
    (select ROUND(AVG(value))
      FROM tutor_db.qualification
      WHERE (id_usr_student = U.user_id AND id_course = SC.id_course AND id_subject = Q.id_subject)) as average_value

FROM tutor_db.qualification Q
     LEFT JOIN tutor_db.user U ON Q.id_usr_student =  U.user_id
     LEFT JOIN tutor_db.subject SB ON Q.id_subject = SB.subject_id AND Q.id_usr_student = U.user_id
     LEFT JOIN tutor_db.grade G ON SB.id_grade = G.grade_id
     LEFT JOIN tutor_db.course C ON G.grade_id = C.id_grade
     LEFT JOIN tutor_db.student_course SC ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.teacher_subject TC ON TC.id_subject = SB.subject_id
     WHERE Q.id_usr_student = student_id
     GROUP BY U.first_name, id_subject, U.last_name, U.user_code, average_value, SB.name, Q.value, Q.test_type, Q.test_date;

END


CREATE DEFINER=`root`@`localhost` PROCEDURE `find_ChildbyTutor`(
    IN `public_id_tutor` VARCHAR(50)
)
BEGIN

DECLARE user_id_tutor INT;

    SELECT user_id INTO user_id_tutor FROM tutor_db.user WHERE public_id = public_id_tutor;

    SELECT
        s.name school_name,
        CONCAT(U.first_name, ' ', U.last_name) student_name,
        U.public_id public_id_child,
        U.user_code,
        U.user_id,
        c.course_id,
        U.age,
        c.name course_name,
        (select count(*) from student_course where id_course = c.course_id) as num_course_students

    FROM tutor_db.user_parent UP
    JOIN tutor_db.user U ON UP.user_id =  U.user_id
    LEFT JOIN tutor_db.user_school us on U.user_id = us.user_id
    LEFT JOIN tutor_db.student_course sc on U.user_id = sc.id_usr_student
    LEFT JOIN tutor_db.course c on c.course_id = sc.id_course
    LEFT JOIN tutor_db.school s on s.school_id = us.school_id
    WHERE UP.parent_id = user_id_tutor;

END ;;
DELIMITER ;


CREATE DEFINER=`root`@`localhost` PROCEDURE `find_InfoUserImage`(public_id_user varchar(200))
BEGIN

DECLARE user_id_variable INT;

    SELECT user_id INTO user_id_variable FROM tutor_db.user WHERE public_id = public_id_user;

 SELECT U.user_id,
 U.id_type,
 U.first_name,
 U.last_name,
 U.phone,
 U.cell_phone,
 U.status,
 U.date,
 U.public_id,
 U.user_code,
 U.id_neighborhood,
 U.document_id,
 U.date_birth,
 U.age,
 U.gender,
 U.email,
 U.user_id,
 UI.url_image

FROM tutor_db.user U
     LEFT JOIN tutor_db.user_image UI ON U.user_id = UI.user_id
     WHERE U.user_id = user_id_variable;
END ;;
DELIMITER ;


CREATE DEFINER=`root`@`localhost` PROCEDURE `find_QualificationByStudent`(course_id int, student_id int, subject_id int)
BEGIN

    SELECT
    CONCAT(U.first_name, ' ', U.last_name) student_name,
    U.user_code,
    SB.name subject_name,
    (select ROUND(AVG(value))
      FROM tutor_db.qualification
      WHERE (id_usr_student = U.user_id AND id_course = SC.id_course AND id_subject = Q.id_subject)) as average_value,
    Q.value,
    Q.test_type,
    Q.test_date

FROM tutor_db.subject SB
     LEFT JOIN tutor_db.grade G ON SB.id_grade = G.grade_id
     LEFT JOIN tutor_db.course C ON G.grade_id = C.id_grade
     LEFT JOIN tutor_db.student_course SC ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.teacher_subject TC ON TC.id_subject = SB.subject_id
     LEFT JOIN tutor_db.user U ON SC.id_usr_student =  U.user_id
     LEFT JOIN tutor_db.qualification Q ON Q.id_subject = SB.subject_id AND Q.id_usr_student = U.user_id
     WHERE Q.id_course = course_id AND Q.id_usr_student = student_id AND Q.id_subject = subject_id
     GROUP BY U.first_name, U.last_name, U.user_code, average_value, SB.name, Q.value, Q.test_type, Q.test_date;

END ;;
DELIMITER ;


CREATE DEFINER=`root`@`localhost` PROCEDURE `find_QualificationBySubject`(course_id int, subject_id int)
BEGIN

    SELECT
    CONCAT(U.first_name, ' ', U.last_name) student_name,
    U.user_code,
    S.name subject_name,
    (select ROUND(AVG(value))
      FROM tutor_db.qualification
      WHERE (id_usr_student = U.user_id AND id_course = Q.id_course AND id_subject = Q.id_subject)) as average_value,
    Q.value,
    H.name as school_name,
    H.name as school_id,
    Q.test_type,
    Q.test_date

FROM tutor_db.qualification Q
     LEFT JOIN tutor_db.subject S ON S.subject_id = Q.id_subject
     LEFT JOIN tutor_db.user U ON Q.id_usr_student = U.user_id
     LEFT JOIN tutor_db.user_school US ON US.user_id = U.user_id
     LEFT JOIN tutor_db.school H ON US.school_id = H.school_id

     WHERE Q.id_course = course_id AND Q.id_subject = subject_id
     GROUP BY U.first_name, U.last_name, U.user_code, average_value, S.name, school_name, school_id, Q.value, Q.test_type, Q.test_date;

END ;;
DELIMITER ;


CREATE DEFINER=`root`@`localhost` PROCEDURE `find_QualificationByUserId`(student_id int)
BEGIN

    SELECT
    CONCAT(U.first_name, ' ', U.last_name) student_name,
    U.user_code,
    SB.name subject_name,
    (select ROUND(AVG(value))
      FROM tutor_db.qualification
      WHERE (id_usr_student = U.user_id AND id_course = SC.id_course AND id_subject = Q.id_subject)) as average_value,
    Q.value,
    Q.test_type,
    Q.test_date

FROM tutor_db.subject SB
     LEFT JOIN tutor_db.grade G ON SB.id_grade = G.grade_id
     LEFT JOIN tutor_db.course C ON G.grade_id = C.id_grade
     LEFT JOIN tutor_db.student_course SC ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.teacher_subject TC ON TC.id_subject = SB.subject_id
     LEFT JOIN tutor_db.user U ON SC.id_usr_student =  U.user_id
     LEFT JOIN tutor_db.qualification Q ON Q.id_subject = SB.subject_id AND Q.id_usr_student = U.user_id
     WHERE Q.id_usr_student = student_id
     GROUP BY U.first_name, U.last_name, U.user_code, average_value, SB.name, Q.value, Q.test_type, Q.test_date;

END ;;
DELIMITER ;


CREATE DEFINER=`root`@`localhost` PROCEDURE `find_SchoolInfobyUser`(public_id_user varchar(200))
BEGIN

DECLARE user_id_variable INT;

    SELECT user_id INTO user_id_variable FROM tutor_db.user WHERE public_id = public_id_user;

SELECT
  S.name as school_name,
  S.school_id,
  S.id_neighborhood,
  S.id_province,
  S.street,
  S.block,
  S.apartment,
  S.logo,
  S.location,
  S.document_id,
  S.school_code,
  S.telephone,
  S.latitude,
  S.longitude,
  S.public_id_school

FROM tutor_db.user U
     LEFT JOIN tutor_db.user_school US ON U.user_id = US.user_id
     LEFT JOIN tutor_db.school S ON US.school_id = S.school_id
     WHERE U.user_id = user_id_variable;
END ;;
DELIMITER ;


CREATE DEFINER=`root`@`localhost` PROCEDURE `find_StudentbySubject`(
  course_id int, school_id int, subject_id int
)
BEGIN

    SELECT DISTINCT CONCAT(U.first_name, ' ', U.last_name) student_name,
    U.user_id,
    U.user_code,
    U.public_id public_id_student,
    UP.parent_id,
    (select public_id FROM tutor_db.user WHERE user_id = UP.parent_id) as public_id_tutor,
    UI.url_image student_image,
    (select AVG(value) FROM tutor_db.qualification WHERE (id_usr_student = U.user_id AND id_course = SC.id_course)) as average_qualification


FROM tutor_db.subject SB
     LEFT JOIN tutor_db.grade G ON SB.id_grade = G.grade_id
     LEFT JOIN tutor_db.course C ON G.grade_id = C.id_grade
     LEFT JOIN tutor_db.student_course SC ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.teacher_subject TC ON TC.id_subject = SB.subject_id
 LEFT JOIN tutor_db.user U ON SC.id_usr_student =  U.user_id
     LEFT JOIN tutor_db.user_parent UP ON UP.user_id = SC.id_usr_student
     LEFT JOIN tutor_db.user_image UI ON UI.user_id = UP.user_id
     LEFT JOIN tutor_db.school S ON TC.id_school = S.school_id
     WHERE SC.id_course = course_id AND S.school_id = school_id AND TC.id_subject = subject_id;
END ;;
DELIMITER ;


CREATE DEFINER=`root`@`localhost` PROCEDURE `find_SubjectByUser`(public_id_teacher varchar(200))
BEGIN
DECLARE user_id_teacher INT;

    SELECT user_id INTO user_id_teacher FROM tutor_db.user WHERE public_id = public_id_teacher;

 SELECT  C.course_id, C.name course_name, SB.subject_id, SB.name subject_name,
SB.time_from, SB.time_to, COUNT(DISTINCT SC.id_usr_student) count_students
FROM tutor_db.subject SB
     LEFT JOIN tutor_db.grade G ON SB.id_grade = G.grade_id
     LEFT JOIN tutor_db.course C ON G.grade_id = C.id_grade
     LEFT JOIN tutor_db.student_course SC ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.teacher_subject TC ON TC.id_subject = SB.subject_id
 LEFT JOIN tutor_db.user U ON TC.id_usr_teacher =  U.user_id AND U.id_type = 3
     WHERE TC.id_usr_teacher = user_id_teacher
     GROUP BY C.course_id, C.name, SB.subject_id, SB.name, SB.time_from, SB.time_to;
END ;;
DELIMITER ;


CREATE DEFINER=`root`@`localhost` PROCEDURE `find_TasksByStudent`(user_id_variable int(11))
BEGIN

SELECT
  S.name as subject_name,
  T.subject_id,
  C.name as course_name,
  SC.id_course,
  T.date,
  T.description,
  T.task_id,
  T.subject_name,
  T.public_id_teacher,
  T.status_teacher

FROM tutor_db.task T
     LEFT JOIN tutor_db.student_course SC ON T.user_id = SC.id_usr_student
     LEFT JOIN tutor_db.course C ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.user U ON T.user_id = U.user_id
     LEFT JOIN tutor_db.subject S ON T.subject_id = S.subject_id
     WHERE U.user_id = user_id_variable;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_ActivitiesByStudent`(student_id int)
BEGIN

    SELECT
    A.activity_id,
    A.student_name,
    A.title,
    A.description,
    A.date,
    A.user_id

FROM tutor_db.activity A
     WHERE A.user_id = student_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_ChildbyTutor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 

'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_ChildbyTutor`(
    IN `public_id_tutor` VARCHAR(50)
)
BEGIN

DECLARE user_id_tutor INT;

    SELECT user_id INTO user_id_tutor FROM tutor_db.user WHERE public_id = public_id_tutor;

    SELECT
        s.name school_name,
        CONCAT(U.first_name, ' ', U.last_name) student_name,
        U.public_id public_id_child,
        U.user_code,
        U.user_id,
        c.course_id,
        U.age,
        c.name course_name,
        (select count(*) from student_course where id_course = c.course_id) as num_course_students

    FROM tutor_db.user_parent UP
    JOIN tutor_db.user U ON UP.user_id =  U.user_id
    LEFT JOIN tutor_db.user_school us on U.user_id = us.user_id
    LEFT JOIN tutor_db.student_course sc on U.user_id = sc.id_usr_student
    LEFT JOIN tutor_db.course c on c.course_id = sc.id_course
    LEFT JOIN tutor_db.school s on s.school_id = us.school_id
    WHERE UP.parent_id = user_id_tutor;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_InfoUserImage` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 

'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_InfoUserImage`(public_id_user varchar(200))
BEGIN

DECLARE user_id_variable INT;

    SELECT user_id INTO user_id_variable FROM tutor_db.user WHERE public_id = public_id_user;

 SELECT U.user_id,
 U.id_type,
 U.first_name,
 U.last_name,
 U.phone,
 U.cell_phone,
 U.status,
 U.date,
 U.public_id,
 U.user_code,
 U.id_neighborhood,
 U.document_id,
 U.date_birth,
 U.age,
 U.gender,
 U.email,
 U.user_id,
 UI.url_image

FROM tutor_db.user U
     LEFT JOIN tutor_db.user_image UI ON U.user_id = UI.user_id
     WHERE U.user_id = user_id_variable;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_QualificationByStudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 

'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_QualificationByStudent`(course_id int, student_id int, subject_id int)
BEGIN

    SELECT
    CONCAT(U.first_name, ' ', U.last_name) student_name,
    U.user_code,
    SB.name subject_name,
    (select ROUND(AVG(value))
      FROM tutor_db.qualification
      WHERE (id_usr_student = U.user_id AND id_course = SC.id_course AND id_subject = Q.id_subject)) as average_value,
    Q.value,
    Q.test_type,
    Q.test_date

FROM tutor_db.subject SB
     LEFT JOIN tutor_db.grade G ON SB.id_grade = G.grade_id
     LEFT JOIN tutor_db.course C ON G.grade_id = C.id_grade
     LEFT JOIN tutor_db.student_course SC ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.teacher_subject TC ON TC.id_subject = SB.subject_id
     LEFT JOIN tutor_db.user U ON SC.id_usr_student =  U.user_id
     LEFT JOIN tutor_db.qualification Q ON Q.id_subject = SB.subject_id AND Q.id_usr_student = U.user_id
     WHERE Q.id_course = course_id AND Q.id_usr_student = student_id AND Q.id_subject = subject_id
     GROUP BY U.first_name, U.last_name, U.user_code, average_value, SB.name, Q.value, Q.test_type, Q.test_date;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_QualificationBySubject` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 

'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_QualificationBySubject`(course_id int, subject_id int)
BEGIN

    SELECT
    CONCAT(U.first_name, ' ', U.last_name) student_name,
    U.user_code,
    S.name subject_name,
    (select ROUND(AVG(value))
      FROM tutor_db.qualification
      WHERE (id_usr_student = U.user_id AND id_course = Q.id_course AND id_subject = Q.id_subject)) as average_value,
    Q.value,
    H.name as school_name,
    H.name as school_id,
    Q.test_type,
    Q.test_date

FROM tutor_db.qualification Q
     LEFT JOIN tutor_db.subject S ON S.subject_id = Q.id_subject
     LEFT JOIN tutor_db.user U ON Q.id_usr_student = U.user_id
     LEFT JOIN tutor_db.user_school US ON US.user_id = U.user_id
     LEFT JOIN tutor_db.school H ON US.school_id = H.school_id

     WHERE Q.id_course = course_id AND Q.id_subject = subject_id
     GROUP BY U.first_name, U.last_name, U.user_code, average_value, S.name, school_name, school_id, Q.value, Q.test_type, Q.test_date;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_QualificationByUserId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 

'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_QualificationByUserId`(student_id int)
BEGIN

    SELECT DISTINCT
    U.user_id,
    CONCAT(U.first_name, ' ', U.last_name) student_name,
    U.user_code,
    SB.name subject_name,
    (select ROUND(AVG(value))
      FROM tutor_db.qualification
      WHERE (id_usr_student = U.user_id AND id_course = SC.id_course AND id_subject = Q.id_subject)) as average_value

FROM tutor_db.subject SB
     LEFT JOIN tutor_db.grade G ON SB.id_grade = G.grade_id
     LEFT JOIN tutor_db.course C ON G.grade_id = C.id_grade
     LEFT JOIN tutor_db.student_course SC ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.teacher_subject TC ON TC.id_subject = SB.subject_id
     LEFT JOIN tutor_db.user U ON SC.id_usr_student =  U.user_id
     LEFT JOIN tutor_db.qualification Q ON Q.id_subject = SB.subject_id AND Q.id_usr_student = U.user_id
     WHERE Q.id_usr_student = student_id
     GROUP BY U.first_name, U.last_name, U.user_code, average_value, SB.name, Q.value, Q.test_type, Q.test_date;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_SchoolInfobyUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 

'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_SchoolInfobyUser`(public_id_user varchar(200))
BEGIN

DECLARE user_id_variable INT;

    SELECT user_id INTO user_id_variable FROM tutor_db.user WHERE public_id = public_id_user;

SELECT
  S.name as school_name,
  S.school_id,
  S.id_neighborhood,
  S.id_province,
  S.street,
  S.block,
  S.apartment,
  S.logo,
  S.location,
  S.document_id,
  S.school_code,
  S.telephone,
  S.latitude,
  S.longitude,
  S.public_id_school

FROM tutor_db.user U
     LEFT JOIN tutor_db.user_school US ON U.user_id = US.user_id
     LEFT JOIN tutor_db.school S ON US.school_id = S.school_id
     WHERE U.user_id = user_id_variable;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_StudentbySubject` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 

'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_StudentbySubject`(
  course_id int, school_id int, subject_id int
)
BEGIN

    SELECT DISTINCT CONCAT(U.first_name, ' ', U.last_name) student_name,
    U.user_id,
    U.user_code,
    U.public_id public_id_student,
    UP.parent_id,
    (select public_id FROM tutor_db.user WHERE user_id = UP.parent_id) as public_id_tutor,
    UI.url_image student_image,
    (select AVG(value) FROM tutor_db.qualification WHERE (id_usr_student = U.user_id AND id_course = SC.id_course)) as average_qualification


FROM tutor_db.subject SB
     LEFT JOIN tutor_db.grade G ON SB.id_grade = G.grade_id
     LEFT JOIN tutor_db.course C ON G.grade_id = C.id_grade
     LEFT JOIN tutor_db.student_course SC ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.teacher_subject TC ON TC.id_subject = SB.subject_id
 LEFT JOIN tutor_db.user U ON SC.id_usr_student =  U.user_id
     LEFT JOIN tutor_db.user_parent UP ON UP.user_id = SC.id_usr_student
     LEFT JOIN tutor_db.user_image UI ON UI.user_id = UP.user_id
     LEFT JOIN tutor_db.school S ON TC.id_school = S.school_id
     WHERE SC.id_course = course_id AND S.school_id = school_id AND TC.id_subject = subject_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_SubjectByUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 

'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_SubjectByUser`(public_id_teacher varchar(200))
BEGIN
DECLARE user_id_teacher INT;

    SELECT user_id INTO user_id_teacher FROM tutor_db.user WHERE public_id = public_id_teacher;

 SELECT  C.course_id, C.name course_name, SB.subject_id, SB.name subject_name,
SB.time_from, SB.time_to, COUNT(DISTINCT SC.id_usr_student) count_students
FROM tutor_db.subject SB
     LEFT JOIN tutor_db.grade G ON SB.id_grade = G.grade_id
     LEFT JOIN tutor_db.course C ON G.grade_id = C.id_grade
     LEFT JOIN tutor_db.student_course SC ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.teacher_subject TC ON TC.id_subject = SB.subject_id
 LEFT JOIN tutor_db.user U ON TC.id_usr_teacher =  U.user_id AND U.id_type = 3
     WHERE TC.id_usr_teacher = user_id_teacher
     GROUP BY C.course_id, C.name, SB.subject_id, SB.name, SB.time_from, SB.time_to;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_TasksByStudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 

'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_TasksByStudent`(user_id_variable int(11))
BEGIN

SELECT
  S.name as subject_name,
  T.subject_id,
  C.name as course_name,
  SC.id_course,
  T.date,
  T.description,
  T.task_id,
  T.subject_name,
  T.public_id_teacher,
  T.status_teacher

FROM tutor_db.task T
     LEFT JOIN tutor_db.student_course SC ON T.user_id = SC.id_usr_student
     LEFT JOIN tutor_db.course C ON SC.id_course = C.course_id
     LEFT JOIN tutor_db.user U ON T.user_id = U.user_id
     LEFT JOIN tutor_db.subject S ON T.subject_id = S.subject_id
     WHERE U.user_id = user_id_variable;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-05-01 22:57:59
