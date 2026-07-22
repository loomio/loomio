# frozen_string_literal: true

class Views::Application::AboutLoomio < Views::BasicLayout
  TITLE = "Loomio is a collaborative decision-making tool"
  DESCRIPTION = "Loomio gives groups and organizations a place to discuss important topics, develop proposals, make decisions together, and keep a clear record of outcomes."

  def initialize(canonical_url:, independently_operated:)
    super(
      title: TITLE,
      description: DESCRIPTION,
      canonical_url: canonical_url,
      lang: :en,
      footer_branding: false
    )
    @independently_operated = independently_operated
  end

  def view_template
    style do
      raw <<~CSS.html_safe
        .about-loomio {
          margin: 3rem auto;
          max-width: 46rem;
          padding: 0 1.5rem;
        }
      CSS
    end

    main(class: "about-loomio") do
      h1 { TITLE }

      p do
        plain "Loomio is used by groups and organizations that share decision-making: cooperatives and self-managing teams, nonprofits and boards, unions, associations and member networks, social and political movements and campaigns, cohousing communities, and ecovillages."
      end

      p do
        plain "It gives people one shared place to discuss important issues, develop proposals, deliberate, run polls and votes, and record clear outcomes."
      end

      p do
        plain "Governance and strategy remain transparent, people can participate whether or not they can attend a meeting, and the reasoning behind each decision remains easy to find."
      end

      p do
        plain "Loomio is open-source software developed by a worker-owned cooperative."
      end

      p do
        a(href: "https://www.loomio.com") { "Visit loomio.com" }
        plain " to explore Loomio's features, read case studies, compare hosting options, and find professional support."
      end

      if @independently_operated
        aside do
          h2 { "This is an independently operated Loomio server" }
          p do
            plain "It is not operated by Loomio Cooperative Limited. Loomio does not provide support for this server and is not responsible for its content."
          end
        end
      end
    end
  end

  private

  def render_head
    super
    script(type: "application/ld+json") do
      raw JSON.generate({
        "@context": "https://schema.org",
        "@type": "AboutPage",
        name: TITLE,
        url: @canonical_url,
        description: DESCRIPTION,
        about: {
          "@type": "SoftwareApplication",
          name: "Loomio",
          url: "https://www.loomio.com",
          applicationCategory: "BusinessApplication",
          operatingSystem: "Web",
          softwareVersion: Version.current,
          creator: {
            "@type": "Organization",
            name: "Loomio Cooperative Limited",
            url: "https://www.loomio.com"
          }
        }
      }).html_safe
    end
  end
end
