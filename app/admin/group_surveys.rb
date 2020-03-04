ActiveAdmin.register GroupSurvey do
  permit_params :group_id, :category, :location, :size, :declaration, :purpose, :usage, :referrer, :role, :website, :misc
end
