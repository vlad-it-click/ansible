## Small note

For `delegate_to` with success to your Ansible-Master (in my case this is my *localhost*) use *[-K | --ask-become-pass]*:

$ `ansible-playbook lessons/18-less/playbook_delegate.yml -K`

