from flytekit import task, workflow

@task
def one() -> None:
    pass

@task
def two() -> None:
    pass

@task
def three() -> None:
    pass

@task
def two_b() -> None:
    pass

@task
def two_c() -> None:
    pass

@task
def two_d() -> None:
    pass

@workflow
def weird_workflow() -> None:
    """Put all of the steps together into a single workflow."""
    one_promise = one()

    two_promise = two()
    two_b_promise = two_b()
    two_c_promise = two_c()
    two_d_promise = two_d()

    three_promise = three()
 
    # one goes before two
    one_promise >> two_promise

    # two goes first then all of the componet parts
    two_promise >> two_b_promise
    two_promise >> two_c_promise
    two_promise >> two_d_promise

    # three waits for all the two parts to be done
    two_b_promise >> three_promise
    two_c_promise >> three_promise
    two_d_promise >> three_promise

