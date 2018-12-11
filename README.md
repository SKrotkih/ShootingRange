# ShootingRange

This is my solution on the following test task: 

Create a thread that adds to a container (List or Array etc) objects (each should be 10 mb size) every 100-500 ms (randomly). Create another thread that deletes objects from this container as soon as possible.
This mechanism should start in a separate modal view controller that has:
⁃UILabel (displays number of deleted objects by the second thread every 1 second).
⁃Close button
Write in objective-c or swift (whatever you want)

I used MVVM with RxSwift, safe access to class fields and some other things.
