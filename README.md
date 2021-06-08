# GenericMail

My first iOS Native App using a Mac Mini, XCode, Objective-C interfacing on a iPhone 3GS.
This repo is no longer maintained.

Problem:
-----------
The business case is to require the customer to signup online for an appointment and providing email.
A email containing the appointment link will be sent to their iPhone.
The customer will open their native email app on their iPhone and tap the connection link, this will auto-register the user and connect them to a session.

Issues:
-----------
1. Apple restricts automation on their native email application
2. Software Engineering department didn't have the time to create a special native email app that allowed QA to automate the web & mobile interactions
3. No one, including the manager didn't have a solution.

Research:
-----------
[If you want something done right, you have to do it yourself]

1. Spent my own money to buy a Mac Mini 2010
2. Company already provided a second hand iPhone 3GS as my test model.
3. Searched online for the original GMail open-source library, called MailCore.
4. MailCore has been abandoned for many years and was broken. So I fixed it. (no excuses)
5. Spent 4 months teaching myself XCode and Objective-C. Never used a Apple product in my life; don't even know how to use the OS.

Ending:
-----------
Created a email native app that can be installed privately that allowed our automation to bridge communication gap between web and mobile.
