module Redirector
  class Destination

    # Lists existing redirects on the bucket
    def existing
      []
    end

    def remove_key(key)
      p [:remove_key, key]
    end

    def write_key(key, location, contents)
      p [:write_key, key, location, contnets]
    end

  end
end