trigger AccountTrigger on Account (before insert, before update) {
  for (Account a : Trigger.new) {
    a.addError('Blocked by trigger updated');
  }
}