export const GROUP_CATEGORY_KEYS = ['board', 'membership', 'self_managing', 'cohousing', 'other'];

export function groupCategoryItems(t) {
  return GROUP_CATEGORY_KEYS.map(category => ({
    value: category,
    title: t(`group_survey.categories.${category}`),
    subtitle: category === 'other' ? undefined : t(`group_survey.category_descriptions.${category}`)
  }));
}
