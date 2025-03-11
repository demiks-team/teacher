enum GroupSessionStatus { zero_, cancelled, requested, postponed }

enum GroupEnrollmentStatus { zero_, open, finished }

enum AttendanceStatus { onTime, late, leftEarly, absent, notSet }

enum ClassDurationType {
  zero_,
  numberOfSessions,
  numberOfHours,
  classEnd,
  rollingClass
}
