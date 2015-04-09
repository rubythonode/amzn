module Services
  class FetchManager
    def fetch
      SearchNode.where(vendor: 'Popshops').find_each do |node|
        opts = { page: last_page_fetched(node), category: node.vendor_id }
        Services::Popshops::ItemFetcher.new(opts).do_request
      end
    end

    private

    def last_page_fetched(node)
      log = Log.searches_for_node(node).first

      if log && log.page_fetched < log.total_pages
        log.page_fetched + 1
      else
        1
      end
    end
  end
end