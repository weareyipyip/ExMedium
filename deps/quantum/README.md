# Quantum

[Cron](https://en.wikipedia.org/wiki/Cron)-like job scheduler for [Elixir](http://elixir-lang.org/).

[![Hex.pm Version](http://img.shields.io/hexpm/v/quantum.svg)](https://hex.pm/packages/quantum)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/quantum)
[![Build Status](https://travis-ci.org/c-rack/quantum-elixir.png?branch=master)](https://travis-ci.org/c-rack/quantum-elixir)
[![Coverage Status](https://coveralls.io/repos/c-rack/quantum-elixir/badge.svg?branch=master)](https://coveralls.io/r/c-rack/quantum-elixir?branch=master)
[![Inline docs](http://inch-ci.org/github/c-rack/quantum-elixir.svg)](http://inch-ci.org/github/c-rack/quantum-elixir)
[![License](https://img.shields.io/badge/license-Apache-brightgreen.svg?style=flat)](http://www.apache.org/licenses/LICENSE-2.0)
[![Hex.pm](https://img.shields.io/hexpm/dt/quantum.svg)](https://hex.pm/packages/quantum)

------

* [Setup](#setup)
* [Usage](#usage)
  * [Named jobs](#named-jobs)
  * [Nodes](#nodes)
  * [Timezone](#timezone)
  * [Crontab format](#crontab-format)
  * [Special expressions](#special-expressions)
  * [Override default settings](#override-default-settings)
* [Contribution](#contribution)
* [License](#license)

------

## Setup

To use Quantum in your project, edit the `mix.exs` file and add Quantum to both

**1. the list of dependencies:**
```elixir
defp deps do
  [{:quantum, ">= 1.7.0"}]
end
```

**2. and the list of applications:**
```elixir
def application do
  [applications: [:quantum]]
end
```

## Usage

Configure your cronjobs in your `config/config.exs` like this:

```elixir
config :quantum, cron: [
    # Every minute
    "* * * * *":      {"Heartbeat", :send},
    # Every 15 minutes
    "*/15 * * * *":   fn -> System.cmd("rm", ["/tmp/tmp_"]) end,
    # Runs on 18, 20, 22, 0, 2, 4, 6:
    "0 18-6/2 * * *": fn -> :mnesia.backup('/var/backup/mnesia') end,
    # Runs every midnight:
    "@daily":         &Backup.backup/0
]
```

or like this:

```elixir
config :quantum, cron: [
    # Every minute
    "* * * * *": {MyApp.MyModule, :my_method}
]
```

or you can provide module as a string:

```elixir
config :quantum, cron: [
    # Every minute
    "* * * * *": {"MyApp.MyModule", :my_method}
]
```

Or even use cron-like format (useful with
[conform](https://github.com/bitwalker/conform) /
[exrm](https://github.com/bitwalker/exrm) /
[edeliver](https://github.com/boldpoker/edeliver)):
```elixir
config :quantum, cron: [
    # Every minute
    "* * * * * MyApp.MyModule.my_method"
]
```

If you want to add jobs on runtime, this is possible too:

```elixir
Quantum.add_job("1 * * * *", fn -> :ok end)
```

### Named jobs

Job struct:
```elixir
%Quantum.Job{
  name: :job_name, # is set automatically on adding a job
  schedule: "1 * * * *", # required
  task: {MyApp.MyModule, :my_method}, # required
  args: [:a, :b] # optional, default: []
  state: :active, # is used for internal purposes
  nodes: [:node@host], # default: [node()]
  overlap: false, # run even if previous job is still running?, default: true
  pid: nil # PID of last executed task
}
```

You can define named jobs in your config like this:

```elixir
config :quantum, cron: [
  news_letter: [
    schedule: "@weekly",
    task: "MyApp.NewsLetter.send", # {MyApp.NewsLetter, :send} is supported too
    args: [:whatever]
  ]
]
```

Possible options:
- `schedule` cron schedule, ex: `"@weekly"` or `"1 * * * *"`
- `task` function to be performed, ex: `"MyApp.MyModule.my_method"` or `{MyApp.MyModule, :my_method}`
- `args` arguments list to be passed to `task`
- `nodes` nodes list the task should be run on, default: `[node()]`
- `overlap` set to false to prevent next job from being executed if previous job is still running, default: `true`

So now you can control your jobs behavior on runtime.

For runtime configuration, job names are not restricted to be atoms.
Strings, atoms and charlists are allowed as job names.

Add named jobs on runtime:

```elixir
job = %Quantum.Job{schedule: "* * * * *", task: fn -> IO.puts "tick" end}
Quantum.add_job("ticker", job)
```

Deactivate job (will not be performed until activation):
```elixir
Quantum.deactivate_job(:ok_job)
Quantum.deactivate_job(:news_letter)
```

Activate inactive job:
```elixir
Quantum.activate_job(:ok_job)
Quantum.activate_job(:news_letter)
```

Find job:
```elixir
Quantum.find_job(:ok_job)
# %Quantum.Job{...}
Quantum.find_job(:news_letter)
# %Quantum.Job{...}
```

Delete job:
```elixir
Quantum.delete_job(:ok_job)
# %Quantum.Job{...}
Quantum.delete_job(:news_letter)
# %Quantum.Job{...}
```

### Nodes

If you need to run a job on a certain node you can define:

```elixir
config :quantum, cron: [
  news_letter: [
    # your job config
    nodes: [:app1@myhost, "app2@myhost"]
  ]
]
```

**NOTE** If `nodes` is not defined current node is used and a job is performed on all nodes.

### Timezone

Please note that Quantum uses **UTC timezone** and not local timezone by default.

To use local timezone, add the following `timezone` option to your configuration:

```elixir
config :quantum,
  cron: [
    # Your cronjobs
  ],
  timezone: :local
```

### Crontab format

| Field        | Allowed values
| ------------ | --------------
| minute       | 0-59
| hour         | 0-23
| day of month | 1-31
| month        | 1-12 (or names)
| day of week  | 0-6 (0 is Sunday, or use names)

Names can also be used for the `month` and `day of week` fields.
Use the first three letters of the particular day or month (case does not matter).

### Special expressions

Instead of the first five fields, one of these special strings may be used:

| String      | Description
| ----------- | -----------
| `@annually` | Run once a year, same as `"0 0 1 1 *"` or `@yearly`
| `@daily`    | Run once a day, same as `"0 0 * * *"` or `@midnight`
| `@hourly`   | Run once an hour, same as `"0 * * * *"`
| `@midnight` | Run once a day, same as `"0 0 * * *"` or `@daily`
| `@monthly`  | Run once a month, same as `"0 0 1 * *"`
| `@reboot`   | Run once, at startup
| `@weekly`   | Run once a week, same as `"0 0 * * 0"`
| `@yearly`   | Run once a year, same as `"0 0 1 1 *"` or `@annually`

### Override default settings

The default job settings can be configured as shown in the example below.
So if you have a lot of jobs and do not want to override the
default setting in every job, you can set them globally.

```elixir
config :quantum,
  cron: [
    # Your cronjobs
  ],
  default_schedule: "* * * * *",
  default_args: ["my api key"],
  default_nodes: [:app1@myhost],
  default_overlap: false
```

## Contribution

This project uses the [C4.1 process](http://rfc.zeromq.org/spec:22) for all code changes.

> "Everyone, without distinction or discrimination, SHALL have an equal right to become a Contributor under the
terms of this contract."

### tl;dr

1. Check for [open issues](https://github.com/c-rack/quantum-elixir/issues) or [open a new issue](https://github.com/c-rack/quantum-elixir/issues/new) to start a discussion around [a problem](https://www.youtube.com/watch?v=_QF9sFJGJuc).
2. Issues SHALL be named as "Problem: _description of the problem_".
3. Fork the [quantum-elixir repository on GitHub](https://github.com/c-rack/quantum-elixir) to start making your changes
4. If possible, write a test which shows that the problem was solved.
5. Send a pull request.
6. Pull requests SHALL be named as "Solution: _description of your solution_"
7. Your pull request is merged and you are added to the [list of contributors](https://github.com/c-rack/quantum-elixir/graphs/contributors)

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
