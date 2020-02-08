/// Contains common flags for mailboxes
enum MailboxFlag {
  marked,
  unMarked,
  hasChildren,
  hasNoChildren,
  noSelect,
  select,
  noInferior,
  subscribed,
  remote,
  nonExistent,
  all,
  inbox,
  sent,
  drafts,
  junk,
  trash,
  archive,
  flagged
}

/// Stores meta data about a folder aka Mailbox
class Mailbox {
  String name;
  String path;
  bool isMarked = false;
  bool hasChildren = false;
  bool isSelected = false;
  bool isUnselectable = false;
  int messagesRecent;
  int messagesExists;
  int firstUnseenMessageSequenceId;
  int uidValidity;
  int uidNext;
  bool isReadWrite = false;
  int highestModSequence;
  List<MailboxFlag> flags = <MailboxFlag>[];
  List<String> messageFlags;
  List<String> permanentMessageFlags;

  bool get isInbox => hasFlag(MailboxFlag.inbox);
  bool get isDrafts => hasFlag(MailboxFlag.drafts);
  bool get isSent => hasFlag(MailboxFlag.sent);
  bool get isJunk => hasFlag(MailboxFlag.junk);
  bool get isTrash => hasFlag(MailboxFlag.trash);
  bool get isArchive => hasFlag(MailboxFlag.archive);

  bool get isSpecialUse =>
      isInbox || isDrafts || isSent || isJunk || isTrash || isArchive;

  Mailbox();
  Mailbox.setup(this.name, this.flags) {
    isMarked = hasFlag(MailboxFlag.marked);
    hasChildren = hasFlag(MailboxFlag.hasChildren);
    isSelected = hasFlag(MailboxFlag.select);
    isUnselectable = hasFlag(MailboxFlag.noSelect);
  }

  bool hasFlag(MailboxFlag flag) {
    return flags.contains(flag);
  }
}