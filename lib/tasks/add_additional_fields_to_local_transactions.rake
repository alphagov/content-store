desc "Update details two existing local_transaction documents with specific fields added"
task add_additional_fields_to_local_transactions: :environment do
  additional_fields_childminder = {
    "cta_text" => "Find a registered childminder in your area",
    "before_results" => "<h2>Find a registered childminder through your local council</h2>",
    "after_results" => "<h2 id=\"find-a-childminder-through-a-registered-childminding-agency\">Find a childminder through a registered childminding agency</h2>
                  <p>You can also search for a childminder using the following childminding agencies:</p>

                  <ul>
                    <li>
                      <p><a rel=\"external\" href=\"https://scachildcare.co.uk/our-childminders/\">Suffolk Childcare Agency</a> (national)</p>
                    </li>
                    <li>
                      <p><a rel=\"external\" href=\"https://www.tiney.co/childminders/\">Tiney</a> (national)</p>
                    </li>
                    <li>
                      <p><a rel=\"external\" href=\"https://www.athomechildcare.co.uk/looking-for-childcare\">@Home Childcare</a> (regional)</p>
                    </li>
                    <li>
                      <p><a rel=\"external\" href=\"https://usearlyyears.co.uk/\">Unique Support Early Years Agency</a> (regional)</p>
                    </li>
                  </ul>",
  }

  childminder = ContentItem.where(content_id: "2f2ee25a-30c8-4ded-a160-88783f978206").first
  childminder.details.merge!(additional_fields_childminder)
  childminder.save!

  additional_fields_foster = {
    "cta_text" => "Find your local council or their regional recruitment hub",
    "before_results" => "<div role=\"note\" aria-label=\"Information\" class=\"application-notice info-notice\">
                          <p>Some local councils recruit foster carers jointly through a regional recruitment hub. If your council is part of a recruitment hub, you’ll be directed to the appropriate website.</p>
                         </div>",
  }

  foster = ContentItem.where(content_id: "4a72fcdf-e0b7-42f0-a606-0636f512453a").first
  foster.details.merge!(additional_fields_foster)
  foster.save!
end
