/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name FROM `Facilities` WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name) as facility FROM `Facilities` WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid AS Facility_id, name AS Facility_name, membercost, monthlymaintenance
FROM `Facilities`
WHERE membercost < 0.2*monthlymaintenance

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * FROM `Facilities` WHERE facid IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
	CASE WHEN monthlymaintenance > 1000 THEN 'Expensive'
	ELSE 'Cheap' END AS $

FROM `Facilities`

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname, MAX(joindate) FROM `Members` WHERE firstname != 'Guest'

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(M.firstname,' ' , M.surname,' ', F.name) as name
FROM Members M
INNER JOIN Bookings B ON M.memid = B.memid
INNER JOIN Facilities F ON B.facid = F.facid
WHERE F.facid = 0 or F.facid = 1
ORDER BY name


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT F.name as facility_name, CONCAT(M.firstname, ' ', M.surname) as member_name, 
	CASE WHEN M.memid > 0 THEN F.membercost*B.slots
		ELSE F.guestcost*B.slots END AS cost
FROM Bookings B JOIN Facilities F ON B.facid = F.facid JOIN Members M ON B.memid = M.memid
WHERE starttime LIKE '2012-09-14%' AND ((M.memid > 0 AND F.membercost*B.slots > 30) OR (M.memid = 0 AND F.guestcost*B.slots > 30))
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT * FROM (SELECT F.name as facility_name, CONCAT(M.firstname, ' ', M.surname) as member_name, 
	CASE WHEN M.memid > 0 THEN F.membercost * B.slots
		ELSE F.guestcost*B.slots END AS cost
FROM Bookings B JOIN Facilities F ON B.facid = F.facid JOIN Members M ON B.memid = M.memid
              WHERE starttime LIKE '2012-09-14%')sub

WHERE sub.cost > 30
ORDER BY sub.cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT * 
    FROM 
     (SELECT sub.facility_name as facility_name, SUM(sub.cost) as revenue 
      FROM
	(SELECT F.name as facility_name,
 		CASE WHEN M.memid > 0 THEN F.membercost * B.slots
		ELSE F.guestcost*B.slots END AS cost
	FROM Bookings B 
 	JOIN Facilities F ON B.facid = F.facid 
 	JOIN Members M ON B.memid = M.memid
    	)sub
      GROUP BY sub.facility_name
    )sub2

WHERE sub2.revenue < 1000
ORDER BY sub2.revenue DESC
