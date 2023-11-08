trigger TestAccountTrigger on Account (after update) {
 Trigger.new.get(0).addError('some error');
}