{if $remoteupdatecode}

    <div align="center">
        {$remoteupdatecode}
    </div>

{else}

    <div class="credit-card">
        <div class="card-icon pull-right">
            <b class="fa fa-2x
            {if $cardtype eq "American Express"}
                fa-cc-amex logo-amex
            {elseif $cardtype eq "Visa"}
                fa-cc-visa logo-visa
            {elseif $cardtype eq "MasterCard"}
                fa-cc-mastercard logo-mastercard
            {elseif $cardtype eq "Discover"}
                fa-cc-discover logo-discover
            {else}
                fa-credit-card
            {/if}">&nbsp;</b>
        </div>
        <div class="card-type">
            {if $cardtype neq "American Express" && $cardtype neq "Visa" && $cardtype neq "MasterCard" && $cardtype neq "Discover"}
                {$cardtype}
            {/if}
        </div>
        <div class="card-number">
            {if $cardlastfour}xxxx xxxx xxxx {$cardlastfour}{else}{$LANG.creditcardnonestored}{/if}
        </div>
        <div class="card-start">
            {if $cardstart}Start: {$cardstart}{/if}
        </div>
        <div class="card-expiry">
            {if $cardexp}Expires: {$cardexp}{/if}
        </div>
        <div class="end"></div>
    </div>

    {if $allowcustomerdelete && $cardtype}
        <form method="post" action="clientarea.php?action=creditcard">
            <input type="hidden" name="remove" value="1" />
            <p class="text-center">
                <button type="submit" class="btn btn-danger">
                    {$LANG.creditcarddelete}
                </button>
            </p>
        </form>
    {/if}

    <h3>{$LANG.creditcardenternewcard}</h3>

    {if $successful}
        {include file="$template/includes/alert.tpl" type="success" msg=$LANG.changessavedsuccessfully textcenter=true}
    {/if}

    {if $errormessage}
        {include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}
    {/if}

    <form class="form-horizontal" role="form" method="post"  id="mainfrm" action="{$smarty.server.PHP_SELF}?action=creditcard">
        <div class="form-group">
          <div id="dropin"></div>   
        </div>
      
          <div class="form-group">
            <div class="text-center">
                <input class="btn btn-primary" type="submit" id="checkoutbutton" value="{$LANG.clientareasavechanges}" />
                <input class="btn btn-default" type="reset" value="{$LANG.cancel}" />
            </div>
        </div>
    </form>

{/if}
