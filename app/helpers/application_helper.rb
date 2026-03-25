module ApplicationHelper
  def render_markdown(text)
    Kramdown::Document.new(text, input: 'GFM', syntax_highlighter: "rouge").to_html
  end

  CARE_ICONS = [
    {
      key: :wash,
      label: "Wash",
      svg: <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M3 6h18l-2 13H5L3 6z"/>
          <path d="M7 12 Q9.5 10 12 12 Q14.5 14 17 12"/>
        </svg>
      SVG
    },
    {
      key: :bleach,
      label: "Bleach",
      svg: <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <polygon points="12,3 21,19 3,19"/>
        </svg>
      SVG
    },
    {
      key: :tumble_dry,
      label: "Tumble Dry",
      svg: <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="3" width="18" height="18" rx="1"/>
          <circle cx="12" cy="12" r="6"/>
        </svg>
      SVG
    },
    {
      key: :iron,
      label: "Iron",
      svg: <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M2 16 L2 18 L18 18 L22 13 L9 13 Z"/>
          <path d="M9 13 L9 9 L15 9"/>
        </svg>
      SVG
    },
    {
      key: :dry_clean,
      label: "Dry Clean",
      svg: <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="9"/>
        </svg>
      SVG
    }
  ].freeze

  def care_icons_for(item)
    CARE_ICONS.map do |icon|
      allowed = case icon[:key]
                when :wash       then item.wash_temp.present?
                when :bleach     then item.bleach_allowed
                when :tumble_dry then item.tumble_dry
                when :iron       then item.iron_allowed
                when :dry_clean  then item.dry_clean
                end
      icon.merge(allowed: allowed)
    end
  end
end
