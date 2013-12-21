---
layout: post
title: "Roadworker - The Best Way to Manage Your Amazon Route53 Records"
date: 2013-11-10 15:43
comments: true
---

## What is Roadworker?

According to [@sgwr_dts](https://twitter.com/sgwr_dts) (the author of roadworker), [Roadworker](https://bitbucket.org/winebarrel/roadworker) is a tool to manage [Amazon Route53](http://aws.amazon.com/en/route53/). It defines the state of Route53 using DSL, and updates Route53 according to DSL.

## Why we should avoid using Route53's web console?

Definitely, Amazon Route53 is one of the best DNS hosting service.

- Highly Available
    - SLA 100%!!
- Cost-Effective
    - basically $0.50 per hosted zone / $0.500 per million queries
- Simple
    - You can start to use within minutes

But Managing Route53 via its web console is slightly painful.

- Not resilient to human error
    - Just a single click may delete a important record
    - Difficult to review before applying
- No changing histories at all
    - After updating many records, it is difficult to revert the original state

Roadworker resolves these issues by defining DNS records as DSL. I'll show how Roadworker can help you in this article.

## Getting Started with Roadworker

Getting started with Roadworker is easy! Open a terminal window and run this command:

```sh
$ gem install roadworker
```

After installing Roadworker, set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for requesting Route53's APIs.

```sh
$ export AWS_ACCESS_KEY_ID='...'
$ export AWS_SECRET_ACCESS_KEY='...'
```

At first, export current records like this:

```sh
$ roadwork -e -o Routefile
```

This is a exported `Routefile`. Easy to manage with git or other VCSs, isn't it?

```ruby
hosted_zone "takus.me." do

  rrset "takus.me.", "A" do
    ttl 3600
    resource_records(
      "219.94.233.169",
    )
  end

  rrset "takus.me.", "MX" do
    ttl 3600
    resource_records(
      "10 mail.takus.me",
    )
  end

  rrset "mail.takus.me.", "A" do
    ttl 3600
    resource_records(
      "219.94.233.169",
    )
  end

  rrset "blog.takus.me.", "CNAME" do
    ttl 3600
    resource_records(
      "takus.github.com",
    )
  end

end
```

As I mentioned above, updating DNS records causes a disaster like deleting unexpected records.
But you can update them safely with `--dry-run` option.
In the case below, I can notice the mistake (deleting the record for this blog) before updating actually.

```sh
$ roadwork --apply --dry-run
Apply `Routefile` to Route53 (dry-run)
Delete ResourceRecordSet: blog.takus.me. CNAME (dry-run)
No change
```

After updating records, you may want to test whether all records are correct state. Roadworker provides `-t` option for comparing the results of a query to the DNS and DSL.

```sh
$ roadwork -t
.......
7 examples, 0 failure
```

## Conclusion

You should use Roadworker for managing Amazon Route53 records instead of its web console. Roadworker enables us to manage DNS records safely with recording all update histories.

## References

- http://rubygems.org/gems/roadworker
- https://bitbucket.org/winebarrel/roadworker
- http://aws.amazon.com/en/route53/
- http://dev.classmethod.jp/cloud/aws/route53-as-code-roadworker/
