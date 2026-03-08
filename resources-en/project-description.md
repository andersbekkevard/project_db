TDT4145 Data modeling and database systems: Project assignment

Problem description
We will create a database for training bookings. Our starting point is SiT Training, which
is described here. SiT Training has several centers in Trondheim: Øya, Gløshaugen,
Dragvoll, Moholt and DMMH. The different centers have different offers. Some have
group lessons, while others only offer self-training. You can find a description of this on
the website of SiT. We want to know the street address of each center and what facilities
they have (various exercises, changing room, shower, sauna, etc.) and what opening
hours they have. We also want to know which rooms they have and whether the center is
staffed and when they are staffed.
The idea with the system is that it should offer booking of group lessons and be able to
register arrivals at the centres. A group class is posted 48 hours before it is held, and it
has a limited number of places, depending entirely on the hall in which the activity is
held. We want you to model some types of group activities that can be found on SiT's
website for training in Trondheim. This is approx. 30 different activities. Of these, you
must include activities marked as "spin". For each type of activity, include the
description of the activity found on the website.
When you book an appointment, you must arrive no later than 5 minutes before the
training session. If you wish to cancel the training, it must be done no later than one hour
before the training. The system must be able to know who is at training and who does not
attend. Those who do not attend will receive a "dot" in the system. If you get 3 dots
within 30 days, you will be banned from online booking until the first dot is older than 30
days.
Spinning gyms have a different number of bikes and they have slightly different bikes in
the gym. Some gym halls have bikes with BodyBike Bluetooth connectivity, i.e. if you
have the BodyBike app on your mobile you can connect to the bike's wattage and
cadence. The database must know which bikes have this characteristic. There is a
number on each bike in the hall.
Treadmills are also of interest in this system. We want to register the treadmills in the
system, knowing who the manufacturer is, what the maximum speed and incline are for
the treadmills. There can be different mills in a hall and they have a number for
identification. We could also consider registering other training equipment at the
centres, but drop this as the task will be large.
Each user of the system must be registered in the system with name, email address and
mobile number. In addition, the system must be able to show who is the instructor for
each exercise. This is shown by a first name of the person. Who is the instructor for a
specific training can change from week to week. The system must be able to register
which activities a user is registered as participating in.
Another use of the training centers we want to include is the sports team's use of the
halls. The sports teams have reserved the halls for many times during the week. We 
would like to register which groups of sports teams have reserved the various halls
during a week. Students have membership in the sports team to be able to use these
hours. They must also have a user in the system like all other users. You must be a
member of the sports team to be able to use these hours.
SiT also needs to obtain statistics for registration for training, so that they can plan for
new semesters. We would like to know the maximum number of registrants for each
session that you can sign up for. Many sessions are very popular and are fully booked
with waiting lists only a short time after they are posted. Many people sign up for the
training before the deadline.
We want you to enter data for a three-day period, i.e. starting on 16 March and ending on
18 March. During this period, we want you to only enter data for activities of the type
"Spinning" at Øya training center and at Dragvoll, i.e. all forms of spinning. Look at SIT's
website for data. If they are unavailable, make up some exercises that you come up with.
Insert facilities, saddles and some bicycles for the Øya training centre. You do not need
to do this for the other gyms.
Use cases
1. Enter the training centre, halls, some bikes, some users, some trainers and
trainings as mentioned above. This must be delivered as SQL.
2. Booking of training "Spin60" on Tuesday 17 March at 18.30 at Øya training center
for user "johnny@stud.ntnu.no". This must be delivered as both Python and SQL.
Let username, activity and time be the parameters, and check that the training
exists before you book.
3. Registration of attendance for the training mentioned in use case 2. User name
and which training should be parameters. This must be delivered as Python and
SQL.
4. Weekly schedule for all training sessions registered in week 12, i.e. from 16 March
to 23 March. This must be sorted by time, i.e. training from different centers must
be merged into the same output. This must be delivered in Python and SQL. Start
day and week should be parameters that are set before running the query.
5. Create a personal visit history for user "johnny@stud.ntnu.no" since 1 January
2026. This can be created in SQL. Make sure there are some training sessions for
Johnny registered in the database. Print which training, training center and
date/time of the training. The result must contain unique rows.
6. Blacklisting. The user 'johnny@stud.ntnu.no' unfortunately received three dots in
the system and will be banned from electronic booking for 30 days. Implement in
Python and SQL. You must check that there are at least three dots within the last
30 days before you blacklist.
7. Every month, the person/persons who have trained the most joint training
sessions are given attention. Create a query that finds the person/those who
have attended the most group lessons in a given month. There may be more than
one person. This can be created in Python and SQL. Remember to include month
as a parameter. Insert somebody who has trained, to show that the query works.
8. Some researchers want to find out if it is common to train together? Suggest a
way to find this out. To simplify the problem, you can assume that you will find
two students who train together. So e-mail, e-mail and the number of joint
training sessions. Write this in SQL. Insert somebody who has trained, to show
that the query works.
