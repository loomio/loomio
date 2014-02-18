title = "<%= get_translation @translation, :title %>";
description = "<%= get_translation @translation, :description %>";
$('.discussion-header-container').find('.translated').html(title);
$('#discussion-context').find('.translated').html(description);