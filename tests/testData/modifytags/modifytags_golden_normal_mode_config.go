package modifytags

import (
	"errors"
	"fmt"
	"time"
)

var ErrNotOnAnyBranch = errors.New("git: not on any branch")

type NotInstalled struct {
	message string
	err     error
}

type PullRequest struct {
	ID                  string
	Number              int
	Title               string
	State               string
	Closed              bool
	URL                 string
	BaseRefName         string
	HeadRefName         string
	HeadRefOid          string `xml:"headRefOid" json:"headRefOid,omitempty"`
	Body                string
	Mergeable           string
	Additions           int
	Deletions           int
	ChangedFiles        int
	MergeStateStatus    string
	IsInMergeQueue      bool
	IsMergeQueueEnabled bool
	CreatedAt           time.Time
	UpdatedAt           time.Time
	ClosedAt            *time.Time
	MergedAt            *time.Time

	Files struct {
		Nodes     []string
		CreatedAt time.Time
		UpdatedAt time.Time
		ClosedAt  *time.Time
		MergedAt  *time.Time
	}
}

func (e *NotInstalled) Error() string {
	return e.message
}

func (e *NotInstalled) Unwrap() error {
	return e.err
}

type GitError struct {
	ExitCode int
	Stderr   string
	err      error
}

func (ge *GitError) Error() string {
	if ge.Stderr == "" {
		return fmt.Sprintf("failed to run git: %v", ge.err)
	}
	return fmt.Sprintf("failed to run git: %s", ge.Stderr)
}

func (ge *GitError) Unwrap() error {
	return ge.err
}
