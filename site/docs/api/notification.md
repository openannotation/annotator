# annotator.notifier package

<div class="function">

annotator.notifier.banner(message\[, severity=notification.INFO\])

Creates a user-visible banner notification that can be used to display
information, warnings and errors to the user.

param String message  
The notice message text.

param severity  
The severity of the notice (one of
<span class="title-ref">notification.INFO</span>,
<span class="title-ref">notification.SUCCESS</span>, or
<span class="title-ref">notification.ERROR</span>)

returns  
An object with a <span class="title-ref">close</span> method that can be
used to close the banner.

</div>
