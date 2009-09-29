BrainBuster - A Logic Captcha For Rails
=======================================

BrainBuster is a logic captcha for Rails.  A logic captcha attempts to detect automated responses (ie spambots) by asking a simple question, such as a word puzzle or math question.  Logic captchas are often easier for humans to answer then image based captchas, but can exclude foreign users or users with cognitive disabilities.  

Some example question and answers are:

"What is fifteen minus five?" => "10"

"Which one of these doesn't fit? 'blue, red, yellow, flower'" => 'flower'

For more on logic captchas and alternate approaches, please see http://www.w3.org/TR/turingtest/#logic

Install
-------

First, install from GitHub:

    script/plugin install git://github.com/rsanheim/brain_buster.git
  
Generate the migration, modifying the stock questions and answers if you wish, and migrate:

    script/generate brain_buster_migration 
    rake db:migrate
    
Optionally set the cookie salt in your ApplicationController (or don't touch it to use the default).  

Add the appropriate filters where you want to use the captcha, and make sure to render the `_captcha` partial in any views where you want to challenge the user with a captcha.  

Details
-------

BrainBuster includes a model for storing questions and answers, a small module that is mixed into ActionController::Bases, a small partial to display the question and input form, and a basic stylesheet for styling the partial.  There is also a "captcha_footer" partial that is not functionally required at all, its just included to make it easy to give credit and a little link-love if you find this useful.  The style sheet is also not required of course, it just has a little bit of clean css for the captcha form.

This captcha is meant to be user-friendly, so for a questions like "What is two plus two", all of the following answers will work: "4", "four", "Four", "   four   ".  By default, a user only needs to answer a captcha _once_, then they are cookied and don't have to answer another question until they close/reopen their browser.

Example
-------

Lets pretend that you have a simple app that displays Pages following fairly standard Rails RESTful conventions.  After initial install and database setup (detailed above), you need to add the filters to the any action(s) you want protected.  

Lets say in PagesController you have a edit action that presents a page to a user in a form, and it posts the change to #update.  So we need to create a captcha before we show the user the edit form, and we need to validate that captcha before we allow the update to succeed.

    class PagesController
      before_filter :create_brain_buster, :only => [:edit]
      before_filter :validate_brain_buster, :only => [:update]
      
      def edit # your normal code is here
      def update # updating your models, etc

Override `render_or_redirect_for_captcha_failure` in your controller, to handle the captcha failure state.  Note that if you *don't override* this method, BrainBuster will just do render :text with the brain buster error message -- this is probably not what you want.

    class PagesController
      
      def render_or_redirect_for_captcha_failure
        render :action => "show"
      end


Render the partial in appropriate templates - if we are creating the captcha for the edit action, we probably need the form rendered in edit.html.erb.

    - edit.html.erb:
      ... inside your form somewhere
      <%= render :partial => '/captcha' %> 

Copy the style sheet into your app's public directory (optional)

    cp vendor/plugins/brain_buster/assets/stylesheets/captcha.css public/stylesheets/             

    # add the style sheet to any views that use the captcha
    <%= stylesheet_link_tag 'captcha' %>

Thats it.  Now if the captcha fails on update, the filter chain will place the failure message into `flash[:error]` and call `render_or_redirect_for_captcha_failure`.  

Troubleshooting
---------------

* If you don't override render_or_redirect_for_captcha_failure, you will see a plain error message for a failed captcha.
* If you delete a question, the random id finder may try to find that deleted question and blow up.  For now, just insert another question with that same id to fix the issue.
* The built in questions and answers could be scripted fairly easily by a determined spammer, but usually just having _some_ defense makes bots move on to easier targets.

Real world usage
----------------
[Tender](https://help.tenderapp.com) uses BrainBuster.

Links
-----
[Homepage](http://github.com/rsanheim/brain_buster) is on GitHub.

[Mailing List](http://groups.google.com/group/brainbuster-discuss) for questions.

[Continuous Integration](http://runcoderun.com/rsanheim/brain_buster) is hosted on RunCodeRun.

Credits
-------
Rob Sanheim started and maintains BrainBuster
Various other folks from [http://thinkrelevance.com](Relevance) have paired and helped with issues