2013-05-11
----------

- Add `kick` and `invite` commands for chatrooms.
- Create moderator table for chatrooms.
- Kicking requires a master profile or user must be a moderator in room.

2013-05-09
----------

- Logging is optional.
- No logging for `#[QuizRoom]`.

2013-05-06
----------

- Minor bugfixes
- More errors added to FAQ.
- Newer and advanced chatrooms.


2013-05-04
----------

- [BOT]Info commands shall work from mainchat too.
- Help command separated for `ToArrival` and `ChatArrival` to avoid duplicate command.
- Report function added to [BOT]Offliner too.
- SQL table schema shared.

2013-04-29
----------

- Added a `Report` function.
- Changed some of the error reports to use `Report()`. The error codes are defined in database.

2013-04-25
----------

- `if`-`else` logic for the *switch* command corrected.

2013-04-15
----------

- A `string.find()` condition removed from if-else block. Will implement if spammers detected.

2013-04-13
----------

- Moderators; when newly added will have their profile changed too, if they are registered. Previously, the if-else logic failed to do so.

2013-04-09
----------

- Buy and sell implemented.
- Minor tweaks as listed below:
    1. Minimum length of message must be 20.
    2. Categories passed will be lowercase.
    3. Previously `readall` command repeated a particular message for all subsequent tables.
- Help file updated with new commands.
- Changed `INNER JOIN` syntax for `dl` command to `LEFT JOIN` to allow deletions for entries without magnets. Using the same to delete replies for Buy and Sell.
- Original users will be notified of any mesages/replies on their buy and sell thread.

2013-04-07
----------

- Create Buy and Sell feature
- Chage git configuration for `core.autocrlf`
- Use IST for dates in chagelogs.

2013-04-06
----------

- Shorten infobot.lua
  1. Change logic.
  2. Remove redundancy.

2013-04-05
----------

- Web-branch updated to use jQuery 1.9.1 now.

2013-04-04
----------

- Added SQL table schema for latest and chat stats.
- Created web-page and web-branch.

2013-04-03
----------

- Infobot updated

2013-04-02
----------

- First commit
- Readme added
- Offliner and Info BOT scripts added.
- File reporting script added.
