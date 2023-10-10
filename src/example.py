from flytekit import task, workflow

@task
def one() -> None:
    pass

@task
def two() -> None:
    pass

@task
def three_a() -> None:
    pass

@task
def three_b() -> None:
    pass

@task
def three_c() -> None:
    pass

@task
def three_d() -> None:
    pass

@task
def four() -> None:
    pass


@workflow
def weird_workflow() -> None:
    """Put all of the steps together into a single workflow."""
    one_promise = one()

    two_promise = two()

    three_a_promise = three_a()
    three_b_promise = three_b()
    three_c_promise = three_c()
    three_d_promise = three_d()

    four_promise = four()
 
    # one goes before two
    one_promise >> two_promise

    # two goes first then all of the three parts
    two_promise >> three_a_promise
    two_promise >> three_b_promise
    two_promise >> three_c_promise
    two_promise >> three_d_promise

    # four waits for all the three parts to be done
    three_a_promise >> four_promise
    three_b_promise >> four_promise 
    three_c_promise >> four_promise
    three_d_promise >> four_promise

if __name__ == "__main__":
    weird_workflow()
