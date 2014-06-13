(function() {
  window.ActiveAdmin = {};

  if (!window.AA) {
    window.AA = window.ActiveAdmin;
  }

}).call(this);
(function() {
  window.ActiveAdmin.CheckboxToggler = ActiveAdmin.CheckboxToggler = (function() {
    function CheckboxToggler(options, container) {
      var defaults;
      this.options = options;
      this.container = container;
      defaults = {};
      this.options = $.extend({}, defaults, options);
      this._init();
      this._bind();
    }

    CheckboxToggler.prototype._init = function() {
      if (!this.container) {
        throw new Error('Container element not found');
      } else {
        this.$container = $(this.container);
      }
      if (!this.$container.find('.toggle_all').length) {
        throw new Error('"toggle all" checkbox not found');
      } else {
        this.toggle_all_checkbox = this.$container.find('.toggle_all');
      }
      return this.checkboxes = this.$container.find(':checkbox').not(this.toggle_all_checkbox);
    };

    CheckboxToggler.prototype._bind = function() {
      this.checkboxes.change((function(_this) {
        return function(e) {
          return _this._didChangeCheckbox(e.target);
        };
      })(this));
      return this.toggle_all_checkbox.change((function(_this) {
        return function() {
          return _this._didChangeToggleAllCheckbox();
        };
      })(this));
    };

    CheckboxToggler.prototype._didChangeCheckbox = function(checkbox) {
      switch (this.checkboxes.filter(':checked').length) {
        case this.checkboxes.length - 1:
          return this.toggle_all_checkbox.prop({
            checked: null
          });
        case this.checkboxes.length:
          return this.toggle_all_checkbox.prop({
            checked: true
          });
      }
    };

    CheckboxToggler.prototype._didChangeToggleAllCheckbox = function() {
      var setting;
      setting = this.toggle_all_checkbox.prop('checked') ? true : null;
      return this.checkboxes.each((function(_this) {
        return function(index, el) {
          $(el).prop({
            checked: setting
          });
          return _this._didChangeCheckbox(el);
        };
      })(this));
    };

    return CheckboxToggler;

  })();

  jQuery(function($) {
    return $.widget.bridge('checkboxToggler', ActiveAdmin.CheckboxToggler);
  });

}).call(this);
(function() {
  window.ActiveAdmin.DropdownMenu = ActiveAdmin.DropdownMenu = (function() {
    function DropdownMenu(options, element) {
      var defaults;
      this.options = options;
      this.element = element;
      this.$element = $(this.element);
      defaults = {
        fadeInDuration: 20,
        fadeOutDuration: 100,
        onClickActionItemCallback: null
      };
      this.options = $.extend({}, defaults, options);
      this.$menuButton = this.$element.find(".dropdown_menu_button");
      this.$menuList = this.$element.find(".dropdown_menu_list_wrapper");
      this.isOpen = false;
      this._buildMenuList();
      this._bind();
    }

    DropdownMenu.prototype.open = function() {
      this.isOpen = true;
      this.$menuList.fadeIn(this.options.fadeInDuration);
      this._positionMenuList();
      this._positionNipple();
      return this;
    };

    DropdownMenu.prototype.close = function() {
      this.isOpen = false;
      this.$menuList.fadeOut(this.options.fadeOutDuration);
      return this;
    };

    DropdownMenu.prototype.destroy = function() {
      this.$element.unbind();
      this.$element = null;
      return this;
    };

    DropdownMenu.prototype.isDisabled = function() {
      return this.$menuButton.hasClass("disabled");
    };

    DropdownMenu.prototype.disable = function() {
      return this.$menuButton.addClass("disabled");
    };

    DropdownMenu.prototype.enable = function() {
      return this.$menuButton.removeClass("disabled");
    };

    DropdownMenu.prototype.option = function(key, value) {
      if ($.isPlainObject(key)) {
        return this.options = $.extend(true, this.options, key);
      } else if (key != null) {
        return this.options[key];
      } else {
        return this.options[key] = value;
      }
    };

    DropdownMenu.prototype._buildMenuList = function() {
      this.$menuList.prepend("<div class=\"dropdown_menu_nipple\"></div>");
      return this.$menuList.hide();
    };

    DropdownMenu.prototype._bind = function() {
      $("body").bind('click', (function(_this) {
        return function() {
          if (_this.isOpen === true) {
            return _this.close();
          }
        };
      })(this));
      return this.$menuButton.bind('click', (function(_this) {
        return function() {
          if (!_this.isDisabled()) {
            if (_this.isOpen === true) {
              _this.close();
            } else {
              _this.open();
            }
          }
          return false;
        };
      })(this));
    };

    DropdownMenu.prototype._positionMenuList = function() {
      var centerOfButtonFromLeft, centerOfmenuListFromLeft, menuListLeftPos;
      centerOfButtonFromLeft = this.$menuButton.position().left + this.$menuButton.outerWidth() / 2;
      centerOfmenuListFromLeft = this.$menuList.outerWidth() / 2;
      menuListLeftPos = centerOfButtonFromLeft - centerOfmenuListFromLeft;
      return this.$menuList.css("left", menuListLeftPos);
    };

    DropdownMenu.prototype._positionNipple = function() {
      var $nipple, bottomOfButtonFromTop, centerOfmenuListFromLeft, centerOfnippleFromLeft, nippleLeftPos;
      centerOfmenuListFromLeft = this.$menuList.outerWidth() / 2;
      bottomOfButtonFromTop = this.$menuButton.position().top + this.$menuButton.outerHeight() + 10;
      this.$menuList.css("top", bottomOfButtonFromTop);
      $nipple = this.$menuList.find(".dropdown_menu_nipple");
      centerOfnippleFromLeft = $nipple.outerWidth() / 2;
      nippleLeftPos = centerOfmenuListFromLeft - centerOfnippleFromLeft;
      return $nipple.css("left", nippleLeftPos);
    };

    return DropdownMenu;

  })();

  (function($) {
    $.widget.bridge('aaDropdownMenu', ActiveAdmin.DropdownMenu);
    return $(function() {
      return $(".dropdown_menu").aaDropdownMenu();
    });
  })(jQuery);

}).call(this);
(function() {
  window.ActiveAdmin.Popover = ActiveAdmin.Popover = (function() {
    function Popover(options, element) {
      var defaults;
      this.options = options;
      this.element = element;
      this.$element = $(this.element);
      defaults = {
        fadeInDuration: 20,
        fadeOutDuration: 100,
        autoOpen: true,
        pageWrapperElement: "#wrapper",
        onClickActionItemCallback: null
      };
      this.options = $.extend({}, defaults, options);
      this.$popover = null;
      this.isOpen = false;
      if ($(this.$element.attr("href")).length > 0) {
        this.$popover = $(this.$element.attr("href"));
      } else {
        this.$popover = this.$element.next(".popover");
      }
      this._buildPopover();
      this._bind();
    }

    Popover.prototype.open = function() {
      this.isOpen = true;
      this.$popover.fadeIn(this.options.fadeInDuration);
      this._positionPopover();
      this._positionNipple();
      return this;
    };

    Popover.prototype.close = function() {
      this.isOpen = false;
      this.$popover.fadeOut(this.options.fadeOutDuration);
      return this;
    };

    Popover.prototype.destroy = function() {
      this.$element.removeData('popover');
      this.$element.unbind();
      this.$element = null;
      return this;
    };

    Popover.prototype.option = function() {};

    Popover.prototype._buildPopover = function() {
      this.$popover.prepend("<div class=\"popover_nipple\"></div>");
      this.$popover.hide();
      return this.$popover.addClass("popover");
    };

    Popover.prototype._bind = function() {
      $(this.options.pageWrapperElement).bind('click', (function(_this) {
        return function(e) {
          if (_this.isOpen === true) {
            return _this.close();
          }
        };
      })(this));
      if (this.options.autoOpen === true) {
        return this.$element.bind('click', (function(_this) {
          return function() {
            if (_this.isOpen === true) {
              _this.close();
            } else {
              _this.open();
            }
            return false;
          };
        })(this));
      }
    };

    Popover.prototype._positionPopover = function() {
      var centerOfButtonFromLeft, centerOfPopoverFromLeft, popoverLeftPos;
      centerOfButtonFromLeft = this.$element.offset().left + this.$element.outerWidth() / 2;
      centerOfPopoverFromLeft = this.$popover.outerWidth() / 2;
      popoverLeftPos = centerOfButtonFromLeft - centerOfPopoverFromLeft;
      return this.$popover.css("left", popoverLeftPos);
    };

    Popover.prototype._positionNipple = function() {
      var $nipple, bottomOfButtonFromTop, centerOfPopoverFromLeft, centerOfnippleFromLeft, nippleLeftPos;
      centerOfPopoverFromLeft = this.$popover.outerWidth() / 2;
      bottomOfButtonFromTop = this.$element.offset().top + this.$element.outerHeight() + 10;
      this.$popover.css("top", bottomOfButtonFromTop);
      $nipple = this.$popover.find(".popover_nipple");
      centerOfnippleFromLeft = $nipple.outerWidth() / 2;
      nippleLeftPos = centerOfPopoverFromLeft - centerOfnippleFromLeft;
      return $nipple.css("left", nippleLeftPos);
    };

    return Popover;

  })();

  (function($) {
    return $.widget.bridge('popover', ActiveAdmin.Popover);
  })(jQuery);

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.ActiveAdmin.TableCheckboxToggler = ActiveAdmin.TableCheckboxToggler = (function(_super) {
    __extends(TableCheckboxToggler, _super);

    function TableCheckboxToggler() {
      return TableCheckboxToggler.__super__.constructor.apply(this, arguments);
    }

    TableCheckboxToggler.prototype._init = function() {
      return TableCheckboxToggler.__super__._init.apply(this, arguments);
    };

    TableCheckboxToggler.prototype._bind = function() {
      TableCheckboxToggler.__super__._bind.apply(this, arguments);
      return this.$container.find('tbody td').click((function(_this) {
        return function(e) {
          if (e.target.type !== 'checkbox') {
            return _this._didClickCell(e.target);
          }
        };
      })(this));
    };

    TableCheckboxToggler.prototype._didChangeCheckbox = function(checkbox) {
      var $row;
      TableCheckboxToggler.__super__._didChangeCheckbox.apply(this, arguments);
      $row = $(checkbox).parents('tr');
      if (checkbox.checked) {
        return $row.addClass('selected');
      } else {
        return $row.removeClass('selected');
      }
    };

    TableCheckboxToggler.prototype._didClickCell = function(cell) {
      return $(cell).parent('tr').find(':checkbox').click();
    };

    return TableCheckboxToggler;

  })(ActiveAdmin.CheckboxToggler);

  jQuery(function($) {
    return $.widget.bridge('tableCheckboxToggler', ActiveAdmin.TableCheckboxToggler);
  });

}).call(this);
(function() {
  $(function() {
    $(document).on('focus', '.datepicker:not(.hasDatepicker)', function() {
      return $(this).datepicker({
        dateFormat: 'yy-mm-dd'
      });
    });
    $('.clear_filters_btn').click(function() {
      return window.location.search = '';
    });
    $('.dropdown_button').popover();
    $('.filter_form').submit(function() {
      return $(this).find(':input').filter(function() {
        return this.value === '';
      }).prop('disabled', true);
    });
    return $('.filter_form_field.select_and_search select').change(function() {
      return $(this).siblings('input').prop({
        name: "q[" + this.value + "]"
      });
    });
  });

}).call(this);
(function() {
  jQuery(function($) {
    $(document).delegate("#batch_actions_selector li a", "click.rails", function() {
      $("#batch_action").val($(this).attr("data-action"));
      return $("#collection_selection").submit();
    });
    if ($("#batch_actions_selector").length && $(":checkbox.toggle_all").length) {
      if ($(".paginated_collection table.index_table").length) {
        $(".paginated_collection table.index_table").tableCheckboxToggler();
      } else {
        $(".paginated_collection").checkboxToggler();
      }
      return $(".paginated_collection").find(":checkbox").bind("change", function() {
        if ($(".paginated_collection").find(":checkbox").filter(":checked").length > 0) {
          return $("#batch_actions_selector").aaDropdownMenu("enable");
        } else {
          return $("#batch_actions_selector").aaDropdownMenu("disable");
        }
      });
    }
  });

}).call(this);



