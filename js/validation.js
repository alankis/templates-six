// add method to validator plugin to check HR phone number with REGEX, according to CARNET API XML schema
$.validator.addMethod("mobileHR", function(phone_number, element) {
	phone_number = phone_number.replace(/\(|\)|\s+|-/g, "");
	return this.optional(element) || phone_number.length > 9 &&
		phone_number.match(/^\+[0-9]{1,3}\.[0-9]{1,14}$/);
}, "Unesite broj u formatu: +385.111234567");

// on document ready, call validation and other methods
$(document).ready(function () {
	// append help block below input
	$("input[name='contactdetails[Registrant][Phone]']").after('<span id="helpBlock" class="help-block">Format broja: +385.11123456789</span>');
	$("input[name='contactdetails[Administrative][Phone]']").after('<span id="helpBlock" class="help-block">Format broja: +385.11123456789</span>');
	$("input[name='contactdetails[Technical][Phone]']").after('<span id="helpBlock" class="help-block">Format broja: +385.11123456789</span>');

	// clear pre populated value on focus 
    var value = $("input[name='contactdetails[Registrant][Phone]']").val();
    
    // log value
    console.log(value);

    // check contactdetails[Registrant][Phone]
    $("input[name='contactdetails[Registrant][Phone]']").click(function() {
    	if ($(this).val() == value)
    	{
    		$(this).val("");
    	}
    	else 
    	{
    		$(this).val(value);
    	}
    });
    $("input[name='contactdetails[Registrant][Phone]']").blur(function(event) {
    	if($(this).val() == "")
    	{
    		$(this).val(value);
    	}
	});

    // check contactdetails[Administrative][Phone]
    $("input[name='contactdetails[Administrative][Phone]']").click(function() {
    	if ($(this).val() == value)
    	{
    		$(this).val("");
    	}
    	else 
    	{
    		$(this).val(value);
    	}
    });
    $("input[name='contactdetails[Administrative][Phone]']").blur(function(event) {
    	if($(this).val() == "")
    	{
    		$(this).val(value);
    	}
	});

    // check contactdetails[Administrative][Phone]
    $("input[name='contactdetails[Technical][Phone]']").click(function() {
    	if ($(this).val() == value)
    	{
    		$(this).val("");
    	}
    	else 
    	{
    		$(this).val(value);
    	}
    });
    $("input[name='contactdetails[Technical][Phone]']").blur(function(event) {
    	if($(this).val() == "")
    	{
    		$(this).val(value);
    	}
	});
	// initialize validation
   	$('.domain-contacts-validation').validate({ 

   		// set immediate validation
   		onkeyup: function (element, event) {
            if (event.which === 9 && this.elementValue(element) === "") {
                return;
            } else {
                this.element(element);
            }
        },
        rules: {
            "contactdetails[Registrant][Phone]": {
                required: true,
                mobileHR: true
            },
            "contactdetails[Administrative][Phone]": {
            	required: true,
            	mobileHR: true
            },
            "contactdetails[Technical][Phone]": {
            	required: true,
            	mobileHR: true
            }
        },
        messages: {
        	"contactdetails[Registrant][Phone]": {
        		required: "Molimo unesite broj telefona"
        	},
        	"contactdetails[Administrative][Phone]": {
        		required: "Molimo unesite broj telefona"
    		},
    		"contactdetails[Technical][Phone]": {
    			required: "Molimo unesite broj telefona"
			}

        }
    });

    // check if form is valid then enable submit button
     $('.domain-contacts-validation input').on('keyup blur', function () {
        if ($('.domain-contacts-validation').valid()) {
            $('.btn-primary').removeClass('btn-disabled');
        } else {
            $('.btn-primary').addClass('btn-disabled');
        }
    });
	
	//do we valid form on document.ready?
    //$('.form-horizontal').valid();

});
